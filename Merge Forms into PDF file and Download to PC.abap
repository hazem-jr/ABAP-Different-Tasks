*&---------------------------------------------------------------------*
*& Report ZTESTING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTESTING.
tables : ekko  .
*& slection screen
SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE text-001 .
   select-OPTIONS : s_ebeln for ekko-ebeln  .
  SELECTION-SCREEN END OF block b1  .

  Parameters:
  p_fname type string  lower case,  " file name ..
  p_path  type string  lower case.  " pdirectory ..

DATA:   LT_FTAB TYPE FILETABLE  ,
        LS_FTAB TYPE FILE_TABLE ,
        G_RC    TYPE SY-SUBRC   .


*& Declarations
data : lt_ekko type table of ekko   ,
       ls_ekko type  ekko  ,
       lt_ekpo type table of ekpo   ,
       ls_ekpo type  ekpo .

data : lt_head type table of zpo_head ,
       ls_head like line of  lt_head  ,
       lt_item type zpo_item_t        ,
       ls_item like line of lt_item   .

DATA: fm_name         TYPE rs38l_fnam,
      fp_docparams    TYPE sfpdocparams,
      fp_outputparams TYPE sfpoutputparams.

data : lt_pdf    type tfpcontent          ,
       ls_pdf    like line of  lt_pdf  .

data : output  type fpformoutput  .

fp_outputparams-nodialog  = abap_true .
*fp_outputparams-preview   = abap_true .
fp_outputparams-getpdf    = 'M' .
fp_outputparams-assemble  = abap_true .
fp_outputparams-bumode    = 'M' .
*fp_outputparams-getpdf    = 'M' .


 AT SELECTION-SCREEN output    .
 

CONCATENATE p_path p_fname into p_path SEPARATED BY '\'.
CONCATENATE p_path '.pdf' into p_path .

*   CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
*    CHANGING
*      FILE_TABLE              =  LT_FTAB
*      RC                      =  G_RC
*    EXCEPTIONS
*      FILE_OPEN_DIALOG_FAILED = 1
*      CNTL_ERROR              = 2
*      ERROR_NO_GUI            = 3
*      NOT_SUPPORTED_BY_GUI    = 4
*      others                  = 5
*          .
*  IF SY-SUBRC <> 0.
*  ENDIF.
*
*  READ TABLE LT_FTAB INTO LS_FTAB INDEX 1.
*  P_path = LS_FTAB-FILENAME.
*  CLEAR : LT_FTAB  , LS_FTAB .

*& Get data ..
START-OF-SELECTION  .
*CONCATENATE p_path p_fname into p_fname SEPARATED BY '\'.
*CONCATENATE p_path '.pdf' into p_fname .

CALL FUNCTION 'FP_JOB_OPEN'
  CHANGING
    IE_OUTPUTPARAMS       = fp_outputparams
 EXCEPTIONS
   CANCEL                = 1
   USAGE_ERROR           = 2
   SYSTEM_ERROR          = 3
   INTERNAL_ERROR        = 4
   OTHERS                = 5 .

select DISTINCT * FROM EKKO INTO TABLE  LT_EKKO
   WHERE EBELN IN S_EBELN  .
SELECT DISTINCT * FROM EKPO INTO TABLE LT_EKPO
  FOR ALL ENTRIES IN LT_EKKO WHERE EBELN = LT_EKKO-EBELN .

SORT LT_EKKO BY EBELN  .
SORT LT_EKPO BY EBELN  .
LOOP AT LT_EKKO INTO LS_EKKO  .
  CLEAR    LS_HEAD  .
  refresh  lt_item  .
  MOVE-CORRESPONDING LS_EKKO TO LS_HEAD  .
  select SINGLE name1 from lfa1 into LS_HEAD-name1 where
     lifnr = ls_head-LIFNR .

*- APPEND ITEMS
  IF LS_HEAD IS NOT INITIAL  .
    LOOP AT LT_EKPO INTO LS_EKPO WHERE EBELN = LS_HEAD-EBELN  .
      CLEAR LS_ITEM  .
      MOVE-CORRESPONDING LS_EKPO TO LS_ITEM  .
      LS_ITEM-SEQ = SY-TABIX  .
      LS_HEAD-total = LS_HEAD-total   + ls_item-BRTWR .       " total
      APPEND LS_ITEM TO LT_ITEM .
      ENDLOOP  .
      perform display_form using ls_head lt_item .
    ENDIF  .
  ENDLOOP  .

  CALL FUNCTION 'FP_JOB_CLOSE'
   EXCEPTIONS
     USAGE_ERROR          = 1
     SYSTEM_ERROR         = 2
     INTERNAL_ERROR       = 3
     OTHERS               = 4
            .



data : merged_forms type xstring  .
data : tmp_form     type xstring  .

  CALL FUNCTION 'FP_GET_PDF_TABLE'
   IMPORTING
     E_PDF_TABLE       = lt_pdf  .
  
*& Concate all xstrings for all forms ...

  loop at lt_pdf  into ls_pdf  .
    clear tmp_form  .
    tmp_form   =  ls_pdf  .
      merged_forms = merged_forms && tmp_form  .
endloop  .

*& convert xstrting to binary ..
data : len type i .
data : lt_content type table of tdline  .


  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer                = merged_forms
*     APPEND_TO_TABLE       = ' '
   IMPORTING
     OUTPUT_LENGTH         = len
    tables
      binary_tab            = lt_content .

*& Download file into pc ..

CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    BIN_FILESIZE                    = len
    filename                        = p_path
   FILETYPE                        = 'BIN'
*   APPEND                          = ' '
*   WRITE_FIELD_SEPARATOR           = ' '
*   HEADER                          = '00'
*   TRUNC_TRAILING_BLANKS           = ' '
*   WRITE_LF                        = 'X'
*   COL_SELECT                      = ' '
*   COL_SELECT_MASK                 = ' '
*   DAT_MODE                        = ' '
*   CONFIRM_OVERWRITE               = ' '
*   NO_AUTH_CHECK                   = ' '
*   CODEPAGE                        = ' '
*   IGNORE_CERR                     = ABAP_TRUE
*   REPLACEMENT                     = '#'
*   WRITE_BOM                       = ' '
*   TRUNC_TRAILING_BLANKS_EOL       = 'X'
*   WK1_N_FORMAT                    = ' '
*   WK1_N_SIZE                      = ' '
*   WK1_T_FORMAT                    = ' '
*   WK1_T_SIZE                      = ' '
*   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*   SHOW_TRANSFER_STATUS            = ABAP_TRUE
*   VIRUS_SCAN_PROFILE              = '/SCET/GUI_DOWNLOAD'
* IMPORTING
*   FILELENGTH                      =
  tables
    data_tab                        = lt_content
*   FIELDNAMES                      =
 EXCEPTIONS
   FILE_WRITE_ERROR                = 1
   NO_BATCH                        = 2
   GUI_REFUSE_FILETRANSFER         = 3
   INVALID_TYPE                    = 4
   NO_AUTHORITY                    = 5
   UNKNOWN_ERROR                   = 6
   HEADER_NOT_ALLOWED              = 7
   SEPARATOR_NOT_ALLOWED           = 8
   FILESIZE_NOT_ALLOWED            = 9
   HEADER_TOO_LONG                 = 10
   DP_ERROR_CREATE                 = 11
   DP_ERROR_SEND                   = 12
   DP_ERROR_WRITE                  = 13
   UNKNOWN_DP_ERROR                = 14
   ACCESS_DENIED                   = 15
   DP_OUT_OF_MEMORY                = 16
   DISK_FULL                       = 17
   DP_TIMEOUT                      = 18
   FILE_NOT_FOUND                  = 19
   DATAPROVIDER_EXCEPTION          = 20
   CONTROL_FLUSH_ERROR             = 21
   OTHERS                          = 22
          .

IF sy-subrc <> 0.
ENDIF.

*&---------------------------------------------------------------------*
*& Form DISPLAY_FORM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_HEAD header data
*&      --> LT_ITEM items
*&---------------------------------------------------------------------*
FORM DISPLAY_FORM  USING    P_LS_HEAD type zpo_head
                            P_LT_ITEM type zpo_item_t .
CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
  EXPORTING
    I_NAME                     = 'ZPO_FORM'
 IMPORTING
   E_FUNCNAME                  =  fm_name
          .
CALL FUNCTION   fm_name     " '/1BCDWB/SM00000014'
 EXPORTING
   /1BCDWB/DOCPARAMS        = fp_docparams
   HEADER                   = P_LS_HEAD
   ITEMS                    = P_LT_ITEM
 IMPORTING
      /1bcdwb/formoutput    = output
 EXCEPTIONS
   USAGE_ERROR              = 1
   SYSTEM_ERROR             = 2
   INTERNAL_ERROR           = 3
   OTHERS                   = 4
          .
ENDFORM.
