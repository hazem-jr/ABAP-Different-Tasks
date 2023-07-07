*&---------------------------------------------------------------------*
*& Report  ZHA_DOUBLE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE ZHA_DOUBLE_TOP                          .    " global Data

* INCLUDE ZHA_DOUBLE_O01                          .  " PBO-Modules
* INCLUDE ZHA_DOUBLE_I01                          .  " PAI-Modules
 INCLUDE ZHA_DOUBLE_F01                          .  " FORM-Routines

INITIALIZATION .

AT SELECTION-SCREEN .

START-OF-SELECTION .
PERFORM GET_DATA .
END-OF-SELECTION .

IF NOT IT_VBAK IS INITIAL .
  PERFORM F_FIELDCAT_ALV .
  PERFORM DISPLAY_DATA .
ENDIF .

FORM DISPLAY_ITEMS USING UCOMM LIKE SY-UCOMM
                    SELFIELD TYPE SLIS_SELFIELD .
  DATA : LT_VBAP TYPE TABLE OF TY_VBAP ,
         ls_vbak type TY_VBAK  .

  CASE UCOMM .
    WHEN '&IC1'.
      Lt_vbap[] = it_vbap[].
      READ TABLE IT_VBAK INTO LS_VBAK INDEX SELFIELD-TABINDEX .
      IF SY-SUBRC IS INITIAL .
        DELETE LT_VBAP WHERE VBELN NE LS_VBAK-VBELN .
        IF NOT LT_VBAP IS INITIAL .
        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
           I_CALLBACK_PROGRAM                = SY-REPID
           IT_FIELDCAT                       =  IT_FCAT1
          TABLES
            T_OUTTAB                          = LT_VBAP
         EXCEPTIONS
           PROGRAM_ERROR                     = 1
           OTHERS                            = 2
                  .
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
       ENDIF.
       ENDIF.

  ENDCASE.
ENDFORM.

**************************************************************************************

*&---------------------------------------------------------------------*
*& Include ZHA_DOUBLE_TOP                                    Report ZHA_DOUBLE
*&
*&---------------------------------------------------------------------*

REPORT ZHA_DOUBLE.
TABLES : VBAK ,VBAP.
type-pools : slis .



SELECTION-SCREEN begin of block b .
select-OPTIONS : s_vbeln for vbak-vbeln .
SELECTION-SCREEN end of block b .

TYPES : BEGIN OF TY_VBAK ,
VBELN	TYPE VBELN_VA ,
ERDAT	TYPE ERDAT ,
ERZET	TYPE ERZET ,
ERNAM	TYPE ERNAM ,
ANGDT	TYPE ANGDT_V ,
BNDDT	TYPE BNDDT ,
AUDAT	TYPE AUDAT ,
VBTYP	TYPE VBTYP ,
TRVOG	TYPE TRVOG ,
AUART	TYPE AUART ,
AUGRU	TYPE AUGRU ,
  END OF TY_VBAK ,

  BEGIN OF TY_VBAP ,
VBELN	TYPE VBELN_VA ,
POSNR	TYPE POSNR_VA ,
MATNR	TYPE MATNR  ,
MATWA	TYPE MATWA  ,
PMATN	TYPE PMATN  ,
CHARG	TYPE CHARG_D ,
MATKL	TYPE MATKL   ,
ARKTX	TYPE ARKTX   ,
END OF TY_VBAP .

  DATA : IT_VBAK TYPE TABLE OF TY_VBAK ,
         WA_VBAK TYPE          TY_VBAK ,

         IT_FCAT TYPE   SLIS_T_FIELDCAT_ALV  ,
         IT_FCAT1 TYPE   SLIS_T_FIELDCAT_ALV  ,
         WA_FCAT TYPE   SLIS_FIELDCAT_ALV    ,
*         WA_FCAT1 TYPE   SLIS_FIELDCAT_ALV    ,

         IT_VBAP TYPE TABLE OF TY_VBAP ,
         WA_VBAP TYPE          TY_VBAP .
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
   I_CALLBACK_PROGRAM                = SY-REPID
   IT_FIELDCAT                       = IT_FCAT
   I_CALLBACK_USER_COMMAND           = 'DISPLAY_ITEMS'
*   I_SAVE                            = 'A '
  TABLES
    T_OUTTAB                          = IT_VBAK
 EXCEPTIONS
   PROGRAM_ERROR                     = 1
   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.


ENDFORM.                    " DISPLAY_DATA

********************************************************************************************************

*&---------------------------------------------------------------------*
*&  Include           ZHA_DOUBLE_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
REFRESH IT_VBAK .
CLEAR   WA_VBAK .

IF NOT S_VBELN IS INITIAL .
SELECT VBELN
ERDAT
ERZET
ERNAM
ANGDT
BNDDT
AUDAT
VBTYP
TRVOG
AUART
AUGRU
  FROM VBAK INTO TABLE IT_VBAK WHERE VBELN IN S_VBELN .
ELSE .
  SELECT VBELN
ERDAT
ERZET
ERNAM
ANGDT
BNDDT
AUDAT
VBTYP
TRVOG
AUART
AUGRU
  FROM VBAK INTO TABLE IT_VBAK UP TO 1000 ROWS.
ENDIF .

IF NOT IT_VBAK IS INITIAL .
  SORT IT_VBAK BY VBELN .
  SELECT VBELN
POSNR
MATNR
MATWA
PMATN
CHARG
MATKL
ARKTX
  FROM VBAP INTO TABLE IT_VBAP FOR ALL ENTRIES IN IT_VBAK WHERE VBELN = IT_VBAK-VBELN .

    IF SY-SUBRC IS INITIAL
      AND NOT IT_VBAP IS INITIAL .
      SORT IT_VBAP  BY VBELN POSNR .
      ENDIF .
ENDIF.



ENDFORM.                    " GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCAT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELDCAT_ALV .
REFRESH IT_FCAT .
CLEAR WA_FCAT   .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '1'.
WA_FCAT-FIELDNAME = 'VBELN'.
WA_FCAT-TABNAME =  'IT_VBAK'.
WA_FCAT-SELTEXT_M = 'SALES DOCUMENT'.
APPEND WA_FCAT TO IT_FCAT .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '2'.
WA_FCAT-FIELDNAME = 'ERDAT'.
WA_FCAT-TABNAME =  'IT_VBAK'.
WA_FCAT-SELTEXT_M = 'DATE'.
APPEND WA_FCAT TO IT_FCAT .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '3'.
WA_FCAT-FIELDNAME = 'ERZET'.
WA_FCAT-TABNAME =  'IT_VBAK'.
WA_FCAT-SELTEXT_M = 'PERSON NAME'.
APPEND WA_FCAT TO IT_FCAT .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '4'.
WA_FCAT-FIELDNAME = 'ERNAM'.
WA_FCAT-TABNAME =  'IT_VBAK'.
WA_FCAT-SELTEXT_M = 'INQUIRY'.
APPEND WA_FCAT TO IT_FCAT .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '5'.
WA_FCAT-FIELDNAME = 'ANGDT'.
WA_FCAT-TABNAME =  'IT_VBAK'.
WA_FCAT-SELTEXT_M = 'VALID TO DATE'.
APPEND WA_FCAT TO IT_FCAT .
CLEAR WA_FCAT .
**************************************************
WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '1'.
WA_FCAT-FIELDNAME = 'VBELN'.
WA_FCAT-TABNAME =  'IT_VBAP'.
WA_FCAT-SELTEXT_M = 'SALES DOCUMENT '.
APPEND WA_FCAT TO IT_FCAT1 .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '2'.
WA_FCAT-FIELDNAME = 'POSNR'.
WA_FCAT-TABNAME =  'IT_VBAP'.
WA_FCAT-SELTEXT_M = 'SALES DOC ITEM'.
APPEND WA_FCAT TO IT_FCAT1 .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '3'.
WA_FCAT-FIELDNAME = 'MATNR'.
WA_FCAT-TABNAME =  'IT_VBAP'.
WA_FCAT-SELTEXT_M = 'MATERIAL NUMBER '.
APPEND WA_FCAT TO IT_FCAT1 .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '4'.
WA_FCAT-FIELDNAME = 'MATWA'.
WA_FCAT-TABNAME =  'IT_VBAP'.
WA_FCAT-SELTEXT_M = 'MATERIAL ENTERED'.
APPEND WA_FCAT TO IT_FCAT1 .
CLEAR WA_FCAT .

WA_FCAT-ROW_POS = '1'.
WA_FCAT-COL_POS = '5'.
WA_FCAT-FIELDNAME = 'PMATNR'.
WA_FCAT-TABNAME =  'IT_VBAP'.
WA_FCAT-SELTEXT_M = 'PRICING REFERENCE MATERIAL'.
APPEND WA_FCAT TO IT_FCAT1 .
CLEAR WA_FCAT .


ENDFORM.                    " F_FIELDCAT_ALV

