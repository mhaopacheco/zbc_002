*&---------------------------------------------------------------------*
*&  Include           ZBCC_LOAD_FILE_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMMC_SUSTITUTOS_MATERIAL_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           Z_ALV_EVENT_HANDLER
*&---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function  OF cl_salv_events       IMPORTING e_salv_function,
      on_link_click   FOR EVENT link_click      OF cl_salv_events_table IMPORTING row column,
      on_double_click FOR EVENT double_click    OF cl_salv_events_table IMPORTING row column.

ENDCLASS.                    "lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.

  ENDMETHOD. "on_user_command

  METHOD on_double_click.
*    READ TABLE
  ENDMETHOD.                    "on_double_click

  METHOD on_link_click.

    BREAK abap01.

    DATA lo_log TYPE REF TO cl_cfa_message_handler.
    DATA ls_log TYPE bapiret2.

    READ TABLE gt_data INTO DATA(gs_data) INDEX row.
    IF sy-subrc EQ 0.
      CASE column.
        WHEN 'ZID_LOG'.

          CALL FUNCTION 'APPL_LOG_DISPLAY'
            EXPORTING
*             OBJECT                    = ' '
*             SUBOBJECT                 = ' '
              external_number           = gs_data-zid_log
*             OBJECT_ATTRIBUTE          = 0
*             SUBOBJECT_ATTRIBUTE       = 0
*             EXTERNAL_NUMBER_ATTRIBUTE = 0
*             DATE_FROM                 = SY-DATUM
*             TIME_FROM                 = '000000'
*             DATE_TO                   = SY-DATUM
*             TIME_TO                   = SY-UZEIT
*             TITLE_SELECTION_SCREEN    = ' '
*             TITLE_LIST_SCREEN         = ' '
*             COLUMN_SELECTION          = '11112221122   '
              suppress_selection_dialog = abap_true
*             COLUMN_SELECTION_MSG_JUMP = '1'
*             EXTERNAL_NUMBER_DISPLAY_LENGTH       = 20
*             I_S_DISPLAY_PROFILE       =
*             I_VARIANT_REPORT          = ' '
*             I_SRT_BY_TIMSTMP          = ' '
*           IMPORTING
*             NUMBER_OF_PROTOCOLS       =
            EXCEPTIONS
              no_authority              = 1
              OTHERS                    = 2.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.

      ENDCASE.
    ENDIF.
  ENDMETHOD.                    "on_double_click

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
