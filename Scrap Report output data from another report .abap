TYPES: BEGIN OF tt,
         line(202),
       END OF tt.

DATA: xlist TYPE abaplist OCCURS 0 WITH HEADER LINE.
DATA: xtext TYPE tt OCCURS 0 WITH HEADER LINE.

DATA: lt_selection TYPE TABLE OF rsparams,
      ls_selection TYPE rsparams.

  CLEAR ls_selection.
  ls_selection-selname = 'P_PLANT'.
  ls_selection-kind = 'S'.
  ls_selection-sign = 'I'.
  ls_selection-option = 'EQ'.
  ls_selection-low = '1020'.
*  ls_selection-low = 'M06001000150000081792'.
  APPEND ls_selection TO lt_selection.


START-OF-SELECTION.

  SUBMIT ZMM_BATCH_TEMPERATURE_REP with SELECTION-TABLE lt_selection EXPORTING LIST TO MEMORY AND RETURN.

  CALL FUNCTION 'LIST_FROM_MEMORY'
    TABLES
      listobject = xlist
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  CALL FUNCTION 'LIST_TO_TXT'
    EXPORTING
      list_index         = -1
    TABLES
      listtxt            = xtext
      listobject         = xlist
    EXCEPTIONS
      empty_list         = 1
      list_index_invalid = 2
      OTHERS             = 3.
