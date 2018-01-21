*&---------------------------------------------------------------------*
*&  Include           ZBDC_COMPACTOR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZBDC_COMPACTOR
*&---------------------------------------------------------------------*
** BI compactor
DEFINE bprepare.
  DATA bdcdata  LIKE TABLE OF bdcdata WITH HEADER LINE.
  DATA messtab LIKE TABLE OF bdcmsgcoll WITH HEADER LINE.
  DATA: opt     LIKE ctu_params.
  REFRESH bdcdata. REFRESH messtab.
END-OF-DEFINITION.
*
DEFINE bd.
  CLEAR bdcdata. bdcdata-program  = &1. bdcdata-dynpro   = &2.
  bdcdata-dynbegin = 'X'. APPEND bdcdata.
END-OF-DEFINITION.
*
DEFINE bf.
  CLEAR bdcdata. bdcdata-fnam = &1. bdcdata-fval = &2.
  APPEND bdcdata.
END-OF-DEFINITION.
************************************************************************
*----------------------------------------------------------------------*
* &1 = TCODE
* &2 = pmode
*    A  Display all screens
*    E  Display Errors
*    N  Background processing
*    P  Background processing; debugging possible
*----------------------------------------------------------------------*
DEFINE bdc_transaction3 .

  DATA: l_mstring(480).
  DATA: l_subrc LIKE sy-subrc.

  REFRESH messtab.
  opt-dismode = &2 .

  CALL TRANSACTION &1 USING bdcdata OPTIONS FROM opt MESSAGES INTO messtab.

*  READ TABLE messtab INTO DATA(ls_messtab) WITH KEY msgid = 'F5' msgnr = '312'  .
*  IF sy-subrc = 0.
*    PERFORM add_row_output USING ud_kunnr ls_messtab-msgv1 'Documento Creado' .
*  ELSE.
*    LOOP AT messtab .
*      SELECT SINGLE * FROM t100 WHERE sprsl = messtab-msgspra
*        AND   arbgb = messtab-msgid
*        AND   msgnr = messtab-msgnr.
*
*      IF sy-subrc = 0 .
*        l_mstring = t100-text .
*        IF l_mstring CS '&1' .
*          REPLACE '&1' WITH messtab-msgv1 INTO l_mstring.
*          REPLACE '&2' WITH messtab-msgv2 INTO l_mstring.
*          REPLACE '&3' WITH messtab-msgv3 INTO l_mstring.
*          REPLACE '&4' WITH messtab-msgv4 INTO l_mstring.
*        ELSE .
*          REPLACE '&' WITH messtab-msgv1 INTO l_mstring.
*          REPLACE '&' WITH messtab-msgv2 INTO l_mstring.
*          REPLACE '&' WITH messtab-msgv3 INTO l_mstring.
*          REPLACE '&' WITH messtab-msgv4 INTO l_mstring.
*        ENDIF .
*        CONDENSE l_mstring.
*        PERFORM add_row_output USING ud_kunnr space l_mstring(250) .
*      ENDIF.
*    ENDLOOP.
*  ENDIF.

  REFRESH bdcdata.

END-OF-DEFINITION.

FORM bdc_transaction  TABLES ct_return  STRUCTURE bapiret2
                             ct_bdcdata STRUCTURE bdcdata
                       USING ud_tcode
                             us_options TYPE ctu_params.

  DATA: l_mstring(480).
  DATA: l_subrc    LIKE sy-subrc,
        lt_messtab TYPE STANDARD TABLE OF bdcmsgcoll.
*  DATA: opt     LIKE ctu_params.

*  opt-dismode = ud_mode .
  CALL TRANSACTION ud_tcode USING ct_bdcdata OPTIONS FROM us_options MESSAGES INTO lt_messtab.

  CALL FUNCTION 'CONVERT_BDCMSGCOLL_TO_BAPIRET2'
    TABLES
      imt_bdcmsgcoll = lt_messtab[]
      ext_return     = ct_return[].

ENDFORM.
