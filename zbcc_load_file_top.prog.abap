*&---------------------------------------------------------------------*
*&  Include           ZMMC_LOAD_MOVS_TOP
*&---------------------------------------------------------------------*
REPORT zmmc_load_movs.


**********************************************************************
* SELECTION-SCREEN
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001 .
PARAMETERS: p_file LIKE rlgrap-filename  OBLIGATORY  DEFAULT 'C:\data.txt',
            p_test TYPE etrue  AS CHECKBOX  DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK a1.

"ToDo4: Descomentariar/Remover dependiendo si es batch o bapi
" OPciones DE bdc = batch input
SELECTION-SCREEN BEGIN OF BLOCK para WITH FRAME TITLE TEXT-t02.
*  PARAMETERS: P_DATASE LIKE RLGRAP-FILENAME OBLIGATORY DEFAULT 'C:_MAT.TXT' .
  PARAMETERS p_mode LIKE ctu_params-dismode DEFAULT 'A'.
  "A: show all dynpros
  "E: show dynpro on error only
  "N: do not display dynpro
SELECTION-SCREEN END OF BLOCK para.
" *******************************************************************
CLASS lcl_handle_events DEFINITION DEFERRED .
**********************************************************************
" Type's ***********************************************************
TYPES : BEGIN OF ty_file,
          data    TYPE c,
          " ToDo03: Aqui reeemplazar data por los campos del archivo de excel
          icon    TYPE icon_d,
          zid_log TYPE balnrext, "Log SLG1
        END OF ty_file.

" Data's ************************************************************
DATA: gt_data           TYPE TABLE OF ty_file,
      gs_data           LIKE LINE OF gt_data[].
