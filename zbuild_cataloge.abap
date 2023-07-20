*&---------------------------------------------------------------------*
*& Include          ZBUILD_CATALOGE
*&---------------------------------------------------------------------*

ls_fcat-fieldname ='LIFNR' .
ls_fcat-seltext_m = 'Vendor code' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NAME1' .
ls_fcat-seltext_m = 'Vendor name' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='belnr' .
ls_fcat-seltext_m = 'Document number' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='BUDAT' .
ls_fcat-seltext_m = 'Posting date' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='BLDAT' .
ls_fcat-seltext_m = 'Document date' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='BTTEXT' .
ls_fcat-seltext_m = 'Business transaction type ' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='UMSKZ' .
ls_fcat-seltext_m = 'special GL ind ' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname = 'PERIOD1' .
ls_fcat-seltext_m = 'First period' .
ls_fcat-emphasize = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL1_D' .
ls_fcat-seltext_m = 'Debit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL1_C' .
ls_fcat-seltext_m = 'Credit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_W1' .
ls_fcat-seltext_m = 'Net Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL1_D' .
ls_fcat-seltext_m = 'Debit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL1_C' .
ls_fcat-seltext_m = 'Credit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_H1' .
ls_fcat-seltext_m = 'Net Amount <Company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RWCUR1' .
ls_fcat-seltext_m = 'Transaction currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RHCUR1' .
ls_fcat-seltext_m = 'Company currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname = 'PERIOD2' .
ls_fcat-seltext_m = 'Second period' .
ls_fcat-emphasize = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL2_D' .
ls_fcat-seltext_m = 'Debit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL2_C' .
ls_fcat-seltext_m = 'Credit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_W2' .
ls_fcat-seltext_m = 'Net Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL2_D' .
ls_fcat-seltext_m = 'Debit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL2_C' .
ls_fcat-seltext_m = 'Credit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_H2' .
ls_fcat-seltext_m = 'Net Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RWCUR2' .
ls_fcat-seltext_m = 'Transaction currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RHCUR2' .
ls_fcat-seltext_m = 'Company currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname = 'PERIOD3' .
ls_fcat-seltext_m = 'Third period' .
ls_fcat-emphasize = 'X' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL3_D' .
ls_fcat-seltext_m = 'Debit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL3_C' .
ls_fcat-seltext_m = 'Credit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_W3' .
ls_fcat-seltext_m = 'Net Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL3_D' .
ls_fcat-seltext_m = 'Debit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL3_C' .
ls_fcat-seltext_m = 'Credit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_H3' .
ls_fcat-seltext_m = 'Net Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RWCUR3' .
ls_fcat-seltext_m = 'Transaction currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RHCUR3' .
ls_fcat-seltext_m = 'Company currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname = 'PERIOD4' .
ls_fcat-seltext_m = 'Fourth period' .
ls_fcat-emphasize = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL4_D' .
ls_fcat-seltext_m = 'Debit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL4_C' .
ls_fcat-seltext_m = 'Credit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_W4' .
ls_fcat-seltext_m = 'Net Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL4_D' .
ls_fcat-seltext_m = 'Debit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL4_C' .
ls_fcat-seltext_m = 'Credit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_H4' .
ls_fcat-seltext_m = 'Net Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RWCUR4' .
ls_fcat-seltext_m = 'Transaction currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RHCUR4' .
ls_fcat-seltext_m = 'Company currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname = 'PERIOD5' .
ls_fcat-seltext_m = 'Fifth period' .
ls_fcat-emphasize = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL5_D' .
ls_fcat-seltext_m = 'Debit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='WSL5_C' .
ls_fcat-seltext_m = 'Credit Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_W5' .
ls_fcat-seltext_m = 'Net Amount <transaction currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL5_D' .
ls_fcat-seltext_m = 'Debit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='HSL5_C' .
ls_fcat-seltext_m = 'Credit Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='NET_H5' .
ls_fcat-seltext_m = 'Net Amount <company currency>' .
ls_fcat-just  = 'X' .
ls_fcat-do_sum = 'X' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RWCUR5' .
ls_fcat-seltext_m = 'Transaction currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

ls_fcat-fieldname ='RHCUR5' .
ls_fcat-seltext_m = 'Company currency' .
APPEND ls_fcat TO lt_fcat .
CLEAR ls_fcat .

*& build sort catalogue ...
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'LIFNR'.
  ls_sort-up        = 'X'.
  ls_sort-subtot    = 'X'.
  APPEND ls_sort TO lt_sort.

DATA fname TYPE string    .
data : lines_no type i , index type sy-tabix .

IF     p2 IS INITIAL  .
  fname = 'PERIOD2' .
ELSEIF p3 IS INITIAL .
  fname = 'PERIOD3' .
ELSEIF p4 IS INITIAL .
  fname = 'PERIOD4' .
ELSEIF p5 IS INITIAL .
  fname = 'PERIOD5' .
ENDIF .

DESCRIBE TABLE lt_fcat LINES lines_no  .
*& clear all unwanted columns from the layout  ...
LOOP AT lt_fcat ASSIGNING FIELD-SYMBOL(<fs>)   .
  if <fs>-fieldname = fname .
      index = sy-tabix  .
    endif  .
  if index is not INITIAL and  sy-tabix >= index and sy-tabix <= lines_no .
   delete TABLE lt_fcat FROM <fs>.
    endif  .

  ENDLOOP .

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    is_layout     = st_layout
    it_fieldcat   = lt_fcat
    it_sort       = lt_sort
  TABLES
    t_outtab      = lt_alv
  EXCEPTIONS
    program_error = 1
    OTHERS        = 2.
