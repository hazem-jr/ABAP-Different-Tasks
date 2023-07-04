*&---------------------------------------------------------------------*
*& Report ZDOWNLOAD_SERVICE_LONGTEXT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDOWNLOAD_SERVICE_LONGTEXT.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001 .
   PARAMETERS : pfile type IBIPPARMS-PATH .
  SELECTION-SCREEN END OF block b1  .

types :  begin of str_down ,
         ASNUM type ASNUM ,
         text(4000) ,
         end of str_down  .

data : gt_down type TABLE OF str_down  ,
       gs_down type str_down .

types : begin of str_head ,
        service(20) ,
        text(20)    ,
        end   of str_head .

data : gt_head type table of str_head ,
       gs_head type          str_head .

at SELECTION-SCREEN on VALUE-REQUEST FOR pfile  .
   CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'PFILE'
    IMPORTING
      file_name  = pfile.

START-OF-SELECTION  .
break mmcon02  .
select DISTINCT ASNUM from asmdt into CORRESPONDING FIELDS OF table gt_down where KZLTX = 'X' .

  if gt_down is NOT INITIAL  .
    loop at gt_down ASSIGNING FIELD-SYMBOL(<fs>) .
      perform read_service_lt using <fs>-ASNUM CHANGING <fs>-TEXT .
      ENDLOOP  .

      perform download_data  .
      endif  .

form read_service_lt  using p_asnum type asnum
                      CHANGING p_text type c .

  data : lines type table of TLINE WITH HEADER LINE  .
  data : name type THEAD-TDNAME  .

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT         = p_asnum
   IMPORTING
     OUTPUT         = p_asnum .

  name = p_asnum .

break mmcon02 .
   CALL FUNCTION 'READ_TEXT'
     EXPORTING
      CLIENT                        = SY-MANDT
       ID                            = 'LTXT'
       LANGUAGE                      = sy-LANGU
       NAME                          = name
       OBJECT                        = 'ASMD'
     TABLES
       LINES                         = lines[]
    EXCEPTIONS
      ID                            = 1
      LANGUAGE                      = 2
      NAME                          = 3
      NOT_FOUND                     = 4
      OBJECT                        = 5
      REFERENCE_CHECK               = 6
      WRONG_ACCESS_TO_ARCHIVE       = 7
      OTHERS                        = 8
             .
   IF SY-SUBRC = 0.
    delete lines[] WHERE TDLINE  = '' .
    loop at lines  .
      CONCATENATE p_text lines into p_text  .
      ENDLOOP  .
   ENDIF.

REFRESH lines  .
clear name  .
  endform  .
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_DATA
*&---------------------------------------------------------------------*
FORM DOWNLOAD_DATA .
 data  filename type string .

 gs_head-SERVICE = 'Servise code' .
 gs_head-TEXT    = 'Long text ' .
 append gs_head to gt_head  .
 CONCATENATE pfile '.xls' into filename  .
*& Download header
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
     FILENAME                        = filename
     FILETYPE                        = 'ASC'
     WRITE_FIELD_SEPARATOR           = 'X'
    TABLES
      DATA_TAB                        = gt_head
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
  IF SY-SUBRC <> 0.
  ENDIF.
*& download data ..
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
     FILENAME                        = filename
     FILETYPE                        = 'DAT'
     APPEND                          = 'X'
     WRITE_FIELD_SEPARATOR           = 'X'
     CODEPAGE                        = '8043'
*     WRITE_BOM                       = 'X'
    TABLES
      DATA_TAB                        = gt_down
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
  IF SY-SUBRC = 0.
    message 'Downloaded succesfully ' type 'S' .
  ENDIF.

ENDFORM.
