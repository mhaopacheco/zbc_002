class ZCL_ALV_OM definition
  public
  create public .

public section.

  methods AUTH_CHECK .
  methods CONSTRUCTOR
    importing
      !I_REPID type SYREPID optional
      !I_PFSTATUS type SYPFKEY optional .
  methods F4_LAYOUTS
    changing
      !C_VARIANT type SLIS_VARI .
  methods GET_DEFAULT_LAYOUT
    changing
      !C_VARIANT type SLIS_VARI .
  methods ON_AFTER_USER_COMMAND
    importing
      !E_SALV_FUNCTION type SALV_DE_FUNCTION .
  methods ON_BEFORE_USER_COMMAND
    for event AFTER_SALV_FUNCTION of CL_SALV_EVENTS .
  methods ON_DOUBLE_CLICK
    for event BEFORE_SALV_FUNCTION of CL_SALV_EVENTS .
  methods ON_END_OF_PAGE
    for event END_OF_PAGE of IF_SALV_EVENTS_LIST
    importing
      !R_END_OF_PAGE
      !PAGE .
  methods ON_LINK_CLICK
    for event IF_SALV_EVENTS_ACTIONS_TABLE~LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
  methods ON_TOP_OF_PAGE
    for event TOP_OF_PAGE of IF_SALV_EVENTS_LIST
    importing
      !R_TOP_OF_PAGE
      !PAGE
      !TABLE_INDEX .
  methods ON_USER_COMMAND
    for event IF_SALV_EVENTS_FUNCTIONS~ADDED_FUNCTION of CL_SALV_EVENTS
    importing
      !E_SALV_FUNCTION .
  methods PUBLISH_ALV
    changing
      !ITAB type TABLE .
  methods SET_REPORT_TITLE
    importing
      !I_TITLE type CSEQUENCE .
protected section.

  data ALV type ref to CL_SALV_TABLE .
  data ALV_MSG type ref to CX_SALV_MSG .
  data PFSTATUS type SYPFKEY .
  data REPID type SYREPID .

  methods PROCESS_FUNCTIONS .
  methods PROCESS_LAYOUT .
  methods PROCESS_REPORT_HEADERS .
  methods PROCESS_TOP_OF_LIST .
  methods PROCESS_TOP_OF_LIST_PRINT .
  methods REGISTER_EVENTS .
  methods SET_COLUMNS .
  methods SET_SELECTION_MODE .
  methods SET_STATUS .
  methods SET_LIKE_POPUP
    importing
      !START_COLUMN type I
      !END_COLUMN type I optional
      !START_LINE type I
      !END_LINE type I optional .
private section.

  data TITLE type STRING .
ENDCLASS.



CLASS ZCL_ALV_OM IMPLEMENTATION.


method AUTH_CHECK.

*  AUTHORITY-CHECK OBJECT 'Z_ABAP_CHK'
*             ID 'BUKRS' DUMMY
*             ID 'ACTVT' DUMMY
*             ID 'WERKS' DUMMY
*             ID 'REPID' FIELD me->repid.
*
*  IF sy-subrc NE 0.
*    MESSAGE e024(zpi).
*  ENDIF.

endmethod.


  METHOD constructor.

    IF i_repid IS SUPPLIED.
      me->repid = i_repid.
    ENDIF.

    IF i_pfstatus IS SUPPLIED.
      me->pfstatus = i_pfstatus.
    ENDIF.

  ENDMETHOD.


method F4_LAYOUTS.

  DATA: ls_layout TYPE salv_s_layout_info,
        ls_key    TYPE salv_s_layout_key.

  ls_key-REPORT = me->repid.

  ls_layout = cl_salv_layout_service=>f4_layouts(
  s_key    = ls_key
  restrict = if_salv_c_layout=>restrict_none ).

  c_variant = ls_layout-layout.

endmethod.


METHOD get_default_layout.

  DATA: ls_layout TYPE salv_s_layout_info,
        ls_key    TYPE salv_s_layout_key.

  ls_key-report = me->repid.

  ls_layout = cl_salv_layout_service=>get_default_layout( s_key    = ls_key
                                                          restrict = if_salv_c_layout=>restrict_none ).

  c_variant = ls_layout-layout.

ENDMETHOD.


method ON_AFTER_USER_COMMAND.
endmethod.


method ON_BEFORE_USER_COMMAND.
endmethod.


method ON_DOUBLE_CLICK.
endmethod.


method ON_END_OF_PAGE.

  DATA: lr_content TYPE REF TO cl_salv_form_element.
  DATA: lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        l_text TYPE string.

*... in the cell [1,1] create header information
  MOVE 'END_OF_PAGE' TO l_text.

*... create a grid
  CREATE OBJECT lr_grid.
  lr_grid->create_header_information(
  row    = 1
  column = 1
  TEXT    = l_text
  tooltip = l_text ).

  lr_content = lr_grid.

*... set the content
  r_end_of_page->set_content( lr_content ).

endmethod.


METHOD on_link_click.


ENDMETHOD.


method ON_TOP_OF_PAGE.

  DATA: lr_content TYPE REF TO cl_salv_form_element.
  DATA: lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        l_text TYPE string.

*... in the cell [1,1] create header information
  MOVE 'TOP_OF_PAGE' TO l_text.

*... create a grid
  CREATE OBJECT lr_grid.
  lr_grid->create_header_information(
  row    = 1
  column = 1
  TEXT    = l_text
  tooltip = l_text ).

  lr_content = lr_grid.
  r_top_of_page->set_content( lr_content ).

endmethod.


method ON_USER_COMMAND.

*      CASE e_salv_function.
*       WHEN 'REP'.
*
*    ENDCASE.

endmethod.


method PROCESS_FUNCTIONS.

*... Functions
*... activate ALV generic Functions
*... include own functions by setting own status
*  alv->set_screen_status(
*    pfstatus      =  'SAPLSLVC_FULLSCREEN'
*    report        =  'SAPLSLVC_FULLSCREEN' "me->repid
*    set_functions = alv->c_functions_all ).

  DATA: lr_functions TYPE REF TO cl_salv_functions_list.
  lr_functions = alv->get_functions( ).
  lr_functions->set_all( abap_true ).
  lr_functions->set_export_xml( abap_true ).
  lr_functions->set_view_lotus( abap_false ).

endmethod.


METHOD process_layout.

*... set layout
  DATA: lr_layout TYPE REF TO cl_salv_layout,
        ls_key    TYPE salv_s_layout_key.

  lr_layout = alv->get_layout( ).

*... set the Layout Key
  ls_key-report = me->repid.
  lr_layout->set_key( ls_key ).

*... set usage of default Layouts
  lr_layout->set_default( abap_true ).

*... set Layout save restriction
  lr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

*... set INITIAL Layout
*  lr_layout->set_initial_layout( '' ).
*  lr_layout->get_initial_layout( ).

ENDMETHOD.


method PROCESS_REPORT_HEADERS.

  me->process_top_of_list( ).
  me->process_top_of_list_print( ).

endmethod.


method PROCESS_TOP_OF_LIST.

  DATA: lr_grid   TYPE REF TO cl_salv_form_layout_grid,
        lf_header TYPE REF TO cl_salv_form_layout_grid,
        lr_grid_1 TYPE REF TO cl_salv_form_layout_grid,
        lr_flow   TYPE REF TO cl_salv_form_layout_flow,
        lr_label  TYPE REF TO cl_salv_form_label,
        lr_text   TYPE REF TO cl_salv_form_text,
        lr_logo   TYPE REF TO cl_salv_form_layout_logo,
        lc_typeid TYPE bds_typeid,
        l_text TYPE string.

  CREATE OBJECT lr_grid.

  IF me->title IS NOT INITIAL.
    lr_grid->create_header_information(
    row    = 1
    column = 1
    TEXT    = me->title
    tooltip = me->title ).
  ENDIF.

*... in the cell [2,1] create a grid
  lr_grid_1 = lr_grid->create_grid(
  row    = 2
  column = 1 ).

*... in the cell [1,1] of the second grid create a label
*  lr_label = lr_grid_1->create_label(
*    row     = 1
*    column  = 1
*    text    = 'Cadbury'
*    tooltip = 'Cadbury' ).

*  lr_flow  = lr_grid_1->create_flow(
*    row     = 2
*    column  = 1 ).

*  lr_label = lr_flow->create_label(
*    text    = 'Program:'(t02)
*    tooltip = 'Program: '(t02) ).

*  lr_text = lr_flow->create_text(
*    text    = sy-cprog
*    tooltip = sy-cprog ).

*  lr_flow  = lr_grid_1->create_flow(
*    row     = 3
*    column  = 1 ).
*
*  lr_label = lr_flow->create_label(
*    text    = 'System:'(t03)
*    tooltip = 'System:'(t03) ).
*
*  lr_text = lr_flow->create_text(
*    text    = sy-sysid
*    tooltip = sy-sysid ).
*
*  lr_flow  = lr_grid_1->create_flow(
*    row     = 3
*    column  = 2 ).
*
*  lr_label = lr_flow->create_label(
*    text    = 'Client:'(t04)
*    tooltip = 'Client:'(t04) ).
*
*  lr_text = lr_flow->create_text(
*    text    = sy-mandt
*    tooltip = sy-mandt ).

  lr_flow  = lr_grid_1->create_flow(
  row     = 4
  column  = 1 ).

  DATA: date1(12) TYPE C.
  DATA: time1(8) TYPE C.
  WRITE sy-datum TO date1.
  WRITE sy-uzeit TO time1.
  DATA: tzonesys TYPE tznzonesys.

  lr_label = lr_flow->create_label(
  TEXT    = 'Fecha:'(t05)
  tooltip = 'Fecha:'(t05) ).

  lr_text = lr_flow->create_text(
  TEXT    = date1
  tooltip = date1 ).


  lr_flow  = lr_grid_1->create_flow(
  row     = 4
  column  = 2 ).
  lr_label = lr_flow->create_label(
  TEXT    = 'Hora:'(t06)
  tooltip = 'Hora:'(t06) ).

  lr_text = lr_flow->create_text(
  TEXT    = time1
  tooltip = time1 ).

  CREATE OBJECT lr_logo.
  lr_logo->set_left_content( lr_grid ).
  lr_logo->set_right_logo( lc_typeid ).

  alv->set_top_of_list( lr_logo ).

endmethod.


method PROCESS_TOP_OF_LIST_PRINT.

  me->process_top_of_list( ).

endmethod.


METHOD publish_alv.

  DATA:
        lr_display TYPE REF TO cl_salv_display_settings,
        l_title    TYPE lvc_title.

  TRY.

    cl_salv_table=>factory(
      EXPORTING list_display = abap_false
      IMPORTING r_salv_table = alv
       CHANGING t_table      = itab ).

  CATCH cx_salv_msg INTO alv_msg.
    MESSAGE alv_msg TYPE 'I'.
    EXIT.
  ENDTRY.

  me->set_status( ).

  lr_display = alv->get_display_settings( ).

  l_title = me->title.

  lr_display->set_list_header( l_title ).

  me->set_selection_mode( ).
  me->process_functions( ).
  me->set_columns( ).
  me->process_layout( ).
  me->register_events( ).
  me->process_report_headers( ).

*  "BEGINOF: MPACHECO:
  DATA : go_columns TYPE REF TO cl_salv_columns_table,
         go_column  TYPE REF TO cl_salv_column.

  go_columns = alv->get_columns( ).
  go_columns->set_optimize( 'X' ).

*  go_column  = go_columns->get_column( 'WERKS' ).
*  go_column->set_visible( abap_false ).
*  FREE go_column .
*  go_column  = go_columns->get_column( 'LGNUM' ).
*  go_column->set_visible( abap_false ).
*  FREE go_column .

*  go_column  = go_columns->get_column( 'BELNR' ).
*  go_column->set_long_text('Recibo de Caja').
*  go_column->set_medium_text('Recibo de Caja').
*  go_column->set_short_text('R. Caja').
*  FREE go_column.
*  go_column  = go_columns->get_column( 'NISTA' ).
*  go_column->set_long_text( 'C.Faltante' ).
*  go_column->set_medium_text( 'C.Faltante' ).
*  go_column->set_short_text( 'C.Faltante' ).
*  FREE go_column.
*  "ENDOF: MPACHECO:

  alv->display( ).

ENDMETHOD.


method REGISTER_EVENTS.

*... register to the events of cl_salv_table
  DATA: lr_events TYPE REF TO cl_salv_events_table.
  lr_events = alv->get_event( ).

*... register to the events (Please only register those events you are u
*  SET HANDLER me->on_user_command        FOR lr_events.
*  SET HANDLER me->on_before_user_command FOR lr_events.
*  SET HANDLER me->on_after_user_command  FOR lr_events.
*  SET HANDLER me->on_double_click        FOR lr_events.
*  SET HANDLER me->on_top_of_page         FOR lr_events.
*  SET HANDLER me->on_end_of_page         FOR lr_events.

endmethod.


METHOD set_columns.

*  DATA(lo_columns) = alv->get_columns( ).
*  lo_columns->set_optimize( abap_true ).
**      value = IF_SALV_C_BOOL_SAP~TRUE
*
*  DATA(lo_column)  = lo_columns->get_column( 'MANDT' ).
*  lo_column->set_visible( abap_false ).
*
*  FREE lo_column.
*  lo_column = lo_columns->get_column('ICON').
*  lo_column->set_long_text('Estado').
*  lo_column->set_alignment( value = if_salv_c_alignment=>centered ).
*
*  FREE lo_column.
*  lo_column = lo_columns->get_column('STATUS').
*  lo_column->set_visible( abap_false ).

ENDMETHOD.


METHOD set_like_popup.

  "     display as popup
  alv->set_screen_popup( start_column = start_column
                              end_column   = end_column
                              start_line   = start_line
                              end_line     = end_line ).

ENDMETHOD.


method SET_REPORT_TITLE.

  me->title = i_title.

endmethod.


METHOD set_selection_mode.

*  DATA(lo_selections) = me->alv->get_selections( ).
*
*  lo_selections->set_selection_mode( EXPORTING value = if_salv_c_selection_mode=>multiple ).
**-- Enabling Selection Mode logic end

ENDMETHOD.


METHOD set_status.

  "use gui-status ST850 from program SAPLKKB
*  alv->set_screen_status( pfstatus      = 'ST850'
*                                report        = 'SAPLKKBL' ).

  IF me->pfstatus IS NOT INITIAL AND me->repid IS NOT INITIAL.
    alv->set_screen_status( report   = me->repid pfstatus = me->pfstatus ).
  ENDIF.

ENDMETHOD.
ENDCLASS.
