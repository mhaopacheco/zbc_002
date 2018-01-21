class ZCL_RUTINES definition
  public
  final
  create public .

public section.

  methods UPLOAD
    importing
      !FILENAME type LOCALFILE
      !HAS_FIELD_SEPARATOR type CHAR1 optional
    exporting
      !SUBRC type SYSUBRC
    changing
      !DATA_TAB type STANDARD TABLE .
  methods UPLOAD_FROM_SERVER
    importing
      !FILENAME type LOCALFILE
      !HAS_FIELD_SEPARATOR type CHAR01
    exporting
      !SUBRC type SYSUBRC
    changing
      !DATA_TAB type STANDARD TABLE .
  methods ADD_MESS_FROM_BDC
    importing
      !LINEA type SYTABIX
      !TYPE type ZE_TYP_ERROR optional
      !MESSAGE type TDLINE optional
      !T_MESS type ZTT_MESS optional
    exporting
      !TAB_LOG type STANDARD TABLE .
  methods ADD_MESS_FROM_BAPI
    importing
      !LINEA type SYTABIX
      !T_MESS_BAPIRET2 type BAPIRET2_TAB
    exporting
      !TAB_LOG type STANDARD TABLE .
  methods DOWNLOAD
    importing
      !FILENAME type STRING
      !WRITE_FIELD_SEPARATOR type CHAR01 optional
    exporting
      value(FILELENGTH) type I
    changing
      !DATA_TAB type STANDARD TABLE .
  methods DOWNLOAD_TO_SERVER
    importing
      !DATA_TAB type STANDARD TABLE
      !FILENAME type STRING
      !HAS_FIELD_SEPARATOR type CHAR01
    exporting
      !SUBRC type SYSUBRC .
  methods BDC_DYNPRO
    importing
      !PROGRAM type BDC_PROG
      !DYNPRO type BDC_DYNR .
  methods BDC_FIELD
    importing
      !FNAM type FNAM_____4
      !FVAL type BDC_FVAL .
  methods BDC_TRANSACTION
    importing
      !TCODE type CHAR20
      !MODE type CHAR1
      !UPDATE type CHAR1
    exporting
      !RET type CHAR1
      !MESS type ZTT_MESS .
  methods BDC_INSERT
    importing
      !TCODE type TSTC-TCODE
      !POST_LOCAL type BDCTH-MTYPE
      !PRINTING type BDCTH-STATE
      !SIMUBATCH type SYBATCH
      !CTUPARAMS type CTU_PARAMS
    exporting
      !SUBRC type SYSUBRC .
  methods BDC_TRANSACTION1
    importing
      !CTU_PARAMS type CTU_PARAMS
      !TCODE type CHAR20
      !MSGID type BDC_MID
      !MSGNR type BDC_MNR
    exporting
      !RET type CHAR1
      !MESS type ZTT_MESS .
  class-methods EXCEL_TO_INTERNAL_TABLE
    importing
      !IP_FILE type LOCALFILE
    exporting
      !ET_EXCEL_TAB type STANDARD TABLE
    raising
      ZCX_RUTINES .
  class-methods CONVERT_EXIT_ALPHA_INPUT
    importing
      !IP_INPUT type CLIKE
    exporting
      !EP_OUTPUT type CLIKE .
  class-methods GET_FILENAME
    importing
      !IP_FILE_LOCATION type CSEQUENCE
      !IP_FILE_FILTER type STRING
    changing
      !CP_FILENAME type CSEQUENCE .
protected section.
private section.

  types TP_CAMPOS type CME_T_DTYPE_NAME .

  data BDCDATA type ZTT_BDCDATA .
  data MESSTAB type ZTT_MESS .
  constants GC_EXCEL_MAX_ROWS type I value 9999 ##NO_TEXT.

  methods OPEN_DATASET
    importing
      !FILENAME type LOCALFILE
    exporting
      !SUBRC type SYSUBRC .
  methods CLOSE_DATASET
    importing
      !FILENAME type LOCALFILE
    exporting
      !SUBRC type SYSUBRC .
  methods OPEN_DATASET_OUTPUT
    importing
      !FILENAME type STRING
    exporting
      !SUBRC type SYSUBRC .
ENDCLASS.



CLASS ZCL_RUTINES IMPLEMENTATION.


  METHOD add_mess_from_bapi.
    DATA: wa_mess   TYPE bapiret2,
          wa_tablog TYPE zst_errlog.

    LOOP AT t_mess_bapiret2 INTO wa_mess.

      IF wa_mess-message IS INITIAL.

        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = wa_mess-id
            msgnr               = wa_mess-number
            msgv1               = wa_mess-message_v1
            msgv2               = wa_mess-message_v2
            msgv3               = wa_mess-message_v3
            msgv4               = wa_mess-message_v4
          IMPORTING
            message_text_output = wa_tablog-message.

      ELSE.
        MOVE wa_mess-message TO wa_tablog-message.
      ENDIF.

      wa_tablog-nline = linea.
      wa_tablog-type  = wa_mess-type.
      APPEND wa_tablog TO tab_log.

    ENDLOOP.

  ENDMETHOD.


  method ADD_MESS_FROM_BDC.
DATA: wa_mess   TYPE bdcmsgcoll,
       wa_tablog TYPE zst_errlog.

  LOOP AT t_mess INTO wa_mess.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = wa_mess-msgid
        msgnr               = wa_mess-msgnr
        msgv1               = wa_mess-msgv1
        msgv2               = wa_mess-msgv2
        msgv3               = wa_mess-msgv3
        msgv4               = wa_mess-msgv4
      IMPORTING
        message_text_output = wa_tablog-message.

    wa_tablog-nline = linea.
    wa_tablog-type = wa_mess-msgtyp.
    APPEND wa_tablog TO tab_log.

  ENDLOOP.

  IF type IS NOT INITIAL OR message IS NOT INITIAL.

    wa_tablog-nline    = linea.
    wa_tablog-type     = type.
    wa_tablog-message  = message.

    APPEND wa_tablog TO tab_log.

  ENDIF.
  endmethod.


  METHOD bdc_dynpro.
    DATA: wa_bdcdata TYPE bdcdata.

    CLEAR wa_bdcdata.

    wa_bdcdata-program  = program.
    wa_bdcdata-dynpro   = dynpro.
    wa_bdcdata-dynbegin = 'X'.

    APPEND wa_bdcdata TO bdcdata.
  ENDMETHOD.


  METHOD bdc_field.
    DATA: wa_bdcdata  TYPE bdcdata.

    CLEAR wa_bdcdata.

    wa_bdcdata-fnam = fnam.
    wa_bdcdata-fval = fval.

    APPEND wa_bdcdata TO bdcdata.
  ENDMETHOD.


  METHOD bdc_insert.
    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode            = tcode
        simubatch        = simubatch
        ctuparams        = ctuparams
      TABLES
        dynprotab        = bdcdata
      EXCEPTIONS
        internal_error   = 1
        not_open         = 2
        queue_error      = 3
        tcode_invalid    = 4
        printing_invalid = 5
        posting_invalid  = 6
        OTHERS           = 7.

    MOVE sy-subrc TO subrc.
    REFRESH bdcdata.
  ENDMETHOD.


  method BDC_TRANSACTION.
   DATA: opt TYPE ctu_params.

  opt-dismode = mode.
  opt-updmode = update.
  opt-racommit = 'X'.

  CALL TRANSACTION tcode USING bdcdata
  OPTIONS FROM opt
  MESSAGES INTO messtab.

  IF sy-subrc NE 0.
    ret = 'N'.
  ENDIF.

  mess[] = messtab[].
  REFRESH bdcdata.

  endmethod.


  METHOD bdc_transaction1.
    DATA wa_mess TYPE bdcmsgcoll.

    CALL TRANSACTION tcode USING bdcdata
                     OPTIONS FROM ctu_params
                     MESSAGES INTO mess.

    REFRESH bdcdata.

    IF msgid IS NOT INITIAL AND msgnr IS NOT INITIAL.
      READ TABLE mess INTO wa_mess WITH KEY msgid = msgid
                                            msgnr = msgnr.
      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT .
      ELSE.
        ROLLBACK WORK.
      ENDIF.
    ELSE.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDMETHOD.


  method CLOSE_DATASET.
  DATA ls_filename TYPE string.

  MOVE filename TO ls_filename.

  CLOSE DATASET ls_filename.

  MOVE sy-subrc TO subrc.

  endmethod.


  method CONVERT_EXIT_ALPHA_INPUT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    INPUT  = ip_input
  IMPORTING
    OUTPUT = ep_output.

  endmethod.


  method DOWNLOAD.
    CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = filename
      write_field_separator   = write_field_separator
    IMPORTING
      filelength              = filelength
    CHANGING
      data_tab                = data_tab
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  endmethod.


  method DOWNLOAD_TO_SERVER.
 DATA: ls_linea    TYPE string,
          lc_filename TYPE localfile,
          li_tabix    TYPE syindex,
          ls_value    TYPE string,
          wa_campo    TYPE LINE OF tp_campos.

  FIELD-SYMBOLS: <wa_data_tab> TYPE ANY,
                 <field>       TYPE ANY.

  CALL METHOD me->open_dataset_output
    EXPORTING
      filename = filename
    IMPORTING
      subrc    = subrc.

  CHECK subrc EQ 0.

  LOOP AT data_tab ASSIGNING <wa_data_tab>.

    DO.

      ADD 1 TO li_tabix.
      ASSIGN COMPONENT li_tabix OF STRUCTURE <wa_data_tab> TO <field>. "se asigna campo a campo
      IF sy-subrc EQ 0.
        MOVE <field> TO ls_value.
        CONCATENATE ls_linea ls_value INTO ls_linea SEPARATED BY has_field_separator.
      ELSE.
        EXIT.
      ENDIF.

    ENDDO.

    SHIFT ls_linea LEFT DELETING LEADING space.
    TRANSFER ls_linea TO filename.
    CLEAR: ls_linea, li_tabix.

  ENDLOOP.

  MOVE filename TO lc_filename.

  CALL METHOD me->close_dataset
    EXPORTING
      filename = lc_filename
    IMPORTING
      subrc    = subrc.
  endmethod.


  METHOD excel_to_internal_table.

  TYPE-POOLS: truxs.

  DATA: lwa_raw TYPE truxs_t_text_data.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
  EXPORTING
*       I_FIELD_SEPERATOR    =
    i_line_header        = 'X'
    i_tab_raw_data       = lwa_raw
    i_filename           = ip_file
  TABLES
    i_tab_converted_data = et_excel_tab
  EXCEPTIONS
    conversion_failed    = 1
    OTHERS               = 2.

  IF sy-subrc <> 0.
    CASE sy-subrc .
    WHEN '1'.
      MESSAGE e001(zca0001) WITH ip_file.
    WHEN OTHERS.
      MESSAGE e002(zca0001) WITH ip_file.
    ENDCASE.
  ENDIF.


  ENDMETHOD.


  method GET_FILENAME.

  DATA:
        ltd_file_table  TYPE filetable,
        lwa_file_line   LIKE LINE OF ltd_file_table,
        li_rc           TYPE sysubrc,
        ls_window_title TYPE string,
        li_user_action  TYPE I.

  CASE ip_file_location.

  WHEN 'LOCAL'.

    ls_window_title = TEXT-001.

    cl_gui_frontend_services=>file_open_dialog(
    EXPORTING
      window_title            = ls_window_title
      file_filter             = ip_file_filter
      multiselection          = abap_false
    CHANGING
      file_table              = ltd_file_table
      rc                      = li_rc
      user_action             = li_user_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5 ).

    IF sy-subrc EQ 0 AND li_rc NE 0.
      READ TABLE ltd_file_table INTO cp_filename INDEX 1.
    ENDIF.

  WHEN 'SERVER'.

    CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory        = ' '
      filemask         = ' ' "?
    IMPORTING
      serverfile       = cp_filename
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.

    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDCASE.

  endmethod.


  method OPEN_DATASET.
  DATA ls_filename TYPE string.

  MOVE filename TO ls_filename.

  OPEN DATASET ls_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT.

  MOVE sy-subrc TO subrc.
  endmethod.


  method OPEN_DATASET_OUTPUT.

  DATA ls_filename TYPE string.

  MOVE filename TO ls_filename.

  OPEN DATASET ls_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

  MOVE sy-subrc TO subrc.
  endmethod.


  METHOD upload.

    DATA: lc_filename	TYPE string.

    MOVE filename TO lc_filename.

    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lc_filename
        has_field_separator     = has_field_separator
      CHANGING
        data_tab                = data_tab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

    MOVE sy-subrc TO subrc.
  ENDMETHOD.


  METHOD upload_from_server.
    DATA: ls_filename TYPE string,
          ls_linea    TYPE string,
          it_campos   TYPE tp_campos,
          li_tabix    TYPE syindex,
          li_index    TYPE syindex,
          wa_campo    TYPE LINE OF tp_campos.

    FIELD-SYMBOLS: <wa_data_tab> TYPE any,
                   <field>       TYPE any.

    CALL METHOD me->open_dataset
      EXPORTING
        filename = filename
      IMPORTING
        subrc    = subrc.

    CHECK subrc EQ 0.

    MOVE filename TO ls_filename.

    DO.

      READ DATASET ls_filename INTO ls_linea.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.

      REFRESH it_campos.

      APPEND INITIAL LINE TO data_tab.
      DESCRIBE TABLE data_tab LINES li_tabix. "registro Actual
      READ TABLE data_tab ASSIGNING <wa_data_tab> INDEX li_tabix. "Se asigna registro actual
      SPLIT ls_linea AT has_field_separator INTO TABLE it_campos. "Tengo registro transpuesto
      CLEAR li_index.

      LOOP AT it_campos INTO wa_campo.
        ADD 1 TO li_index.
        ASSIGN COMPONENT li_index OF STRUCTURE <wa_data_tab> TO <field>. "se asigna campo a campo
        <field> = wa_campo.
      ENDLOOP.

    ENDDO.

    DESCRIBE TABLE data_tab LINES li_tabix. "total registros
    IF li_tabix GT 0.
      CLEAR subrc.
    ELSE.
      subrc = 1.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
