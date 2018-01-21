*&---------------------------------------------------------------------*
*&  Include           ZMMC_LOAD_MOVS_F01
*&---------------------------------------------------------------------*

FORM get_filename  USING pfile.
  DATA: lst_file TYPE file_table OCCURS 0,
        rc       TYPE i,
        txt_g00  TYPE string.

  txt_g00 = TEXT-g00.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = txt_g00
      default_extension       = '.'
    CHANGING
      file_table              = lst_file
      rc                      = rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      OTHERS                  = 5.

  CHECK sy-subrc = 0.
  READ TABLE lst_file INDEX 1 INTO p_file .

ENDFORM.

**********************************************************************
FORM load_file.

  DATA name_file                TYPE string.
  name_file = p_file .

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename            = name_file
      filetype            = 'ASC'
      has_field_separator = 'X'
    CHANGING
      data_tab            = gt_data[]
    EXCEPTIONS
      file_open_error     = 1
      file_read_error     = 2
      bad_data_format     = 3
      OTHERS              = 5.

  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN : '1'.
        WRITE :/ 'Error al abrir el archivo:', p_file.
      WHEN : '2'.
        WRITE :/ 'Error al leer el archivo:', p_file.
      WHEN : '3'.
        WRITE :/ 'Error de formato en el archivo:', p_file.
      WHEN OTHERS.
        MESSAGE e301(bd) WITH p_file.
    ENDCASE.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXECUTE_LOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM execute_load .

  "MPACHECO: 09.11.2017 09:12:20: Aqui va pegar el codigo que se genera
  "de la grabación, aqui se crean los paquetes a enviar al bdc o la bapi

  DATA: lt_return   TYPE STANDARD TABLE OF bapiret2 .

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_data>).
*    PERFORM call_bapi TABLES lt_return[] CHANGING <ls_data>  .
    PERFORM call_bdc TABLES lt_return[] CHANGING <ls_data> .
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_alv .

  "MPACHECO: 09.11.2017 09:11:58: Aqui Va el patron de #salv2
  DATA: lo_display_settings TYPE REF TO cl_salv_display_settings,
        lo_alv              TYPE REF TO cl_salv_table,
*          lo_functions        TYPE REF TO cl_salv_functions,        " Funciones ALV
        lo_columns          TYPE REF TO cl_salv_columns_table,
        lo_column           TYPE REF TO cl_salv_column,
        lo_hl_events        TYPE REF TO lcl_handle_events,
        lo_events           TYPE REF TO cl_salv_events_table,
        lo_message          TYPE REF TO cx_salv_msg  ##NEEDED.
  TRY .

      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = lo_alv    " Basis Class Simple ALV Tables
        CHANGING
          t_table      = gt_data[].

    CATCH cx_salv_msg INTO lo_message ##NO_HANDLER.
  ENDTRY.

*  ---- Funciones estandar ALV
  lo_alv->get_functions( )->set_all( abap_true ).

*  ---- Titulo del alv
  lo_display_settings = lo_alv->get_display_settings( ).
  lo_display_settings->set_list_header( TEXT-001 ).
  lo_display_settings->set_striped_pattern( abap_true ).

*  ---- Obtengo Todas las Columnas del catalogo
  lo_columns = lo_alv->get_columns( ).
  lo_columns->set_optimize( abap_true ).

  PERFORM view_alv USING    lo_columns
                   CHANGING lo_column.

  CREATE OBJECT lo_hl_events.
  lo_events = lo_alv->get_event( ).
  SET HANDLER lo_hl_events->on_link_click FOR lo_events.

  lo_alv->display( ).


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  TRANSFORM_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM transform_data .

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  VIEW_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LO_COLUMNS  text
*      <--P_LO_COLUMN  text
*----------------------------------------------------------------------*
FORM view_alv  USING    lo_columns TYPE REF TO cl_salv_columns_table
              CHANGING  lo_column  TYPE REF TO cl_salv_column.

  DATA: lt_columns TYPE         salv_t_column_ref,        " Todas las Columnas del ALV
        ls_columns TYPE         salv_s_column_ref.        " WA para tabla LT_COLUMNS

  DATA lo_column_table TYPE REF TO cl_salv_column_table.

*---- Formato a Columnas
*-- Obtiene todas las columnas y las formatea una X una
  lt_columns = lo_columns->get( ).

  LOOP AT lt_columns INTO ls_columns.
    TRY .
        lo_column = ls_columns-r_column.
        lo_column_table ?= lo_columns->get_column( ls_columns-columnname ).
        CASE ls_columns-columnname.
          WHEN 'ZID_LOG'.
            lo_column_table->set_cell_type( if_salv_c_cell_type=>hotspot ).
            lo_column->set_short_text( 'Log' ).
            lo_column->set_medium_text( 'Log' ).
            lo_column->set_long_text( 'Log' ).
          WHEN 'ICON' .
            lo_column->set_short_text( 'Ok' ).
            lo_column->set_medium_text( 'Ok' ).
            lo_column->set_long_text( 'Ok' ).
        ENDCASE.
      CATCH  cx_salv_not_found ##NO_HANDLER.
      CATCH cx_salv_data_error ##NO_HANDLER.

    ENDTRY.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILL_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CT_RETURN[]  text
*      <--P_CS_DATA  text
*----------------------------------------------------------------------*
FORM fill_output  TABLES   ct_return STRUCTURE bapiret2
                  CHANGING cs_data   STRUCTURE gs_data .

  READ TABLE ct_return INTO DATA(ls_return) WITH KEY type = 'E'.
  IF sy-subrc = 0.
    cs_data-icon = '@0A@' . "Error
  ELSE.
    cs_data-icon = '@08@' . "Success
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALL_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RETURN[]  text
*      <--P_<LS_DATA>  text
*----------------------------------------------------------------------*
FORM call_bdc  TABLES   ct_return STRUCTURE bapiret2
               CHANGING cs_data   STRUCTURE gs_data .

  "MPACHECO: 09.11.2017 09:12:20: Aqui va pegar el codigo que se genera de la grabación
  bprepare.

  "ToDo7: Reemplazar el siguiente codigo por el generado en la pagina
**  ** DYNPRO **********************
*  bd 'SAPLMGMW'             '0100'.
*  bf 'RMMW1-MATNR'          cs_data-material .
*  bf 'RMMW1-VZWRK'          cs_data-plant .
*  bf 'MSICHTAUSW-KZSEL(06)' 'X' .
*  bf 'BDC_OKCODE' '/00'.
*
**  ** DYNPRO **********************
*  bd 'SAPLMGMW'   '4004'.
*  bf 'MARC-LGFSB' cs_data-stge_loc.
*  bf 'MARD-LGPBE' cs_data-stge_bin.
*  bf 'BDC_OKCODE' '=BU'.

*** CALL TRANSACTION **********************
*  CALL TRANSACTION 'MM42' USING bdcdata MODE p_mode UPDATE 'L' MESSAGES INTO messtab.
  DATA: ls_options    TYPE ctu_params .
  ls_options-dismode = p_mode .

  PERFORM bdc_transaction TABLES ct_return[] bdcdata USING 'MM42' ls_options .

  PERFORM fill_output TABLES ct_return[] CHANGING cs_data .

ENDFORM.
