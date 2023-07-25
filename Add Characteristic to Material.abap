*&---------------------------------------------------------------------*
*& Report ZHA_TEST444
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zha_test444.

DATA : objectkeynew   LIKE  bapi1003_key-object,
       objecttablenew LIKE  bapi1003_key-objecttable,
       classnumnew    LIKE  bapi1003_key-classnum,
       classtypenew   LIKE  bapi1003_key-classtype.

DATA : lt_characteristic TYPE TABLE OF bapi1003_alloc_values_num, ls_chars TYPE bapi1003_alloc_values_num,
       lt_return         TYPE TABLE OF bapiret2.


objectkeynew = '1209X'.
objecttablenew = 'MARA' .
classnumnew = 'LAST_GR_DATE' .
classtypenew = '001' .


ls_chars-charact =  'GR_DATE'.
ls_chars-value_from =  '20201212'.

APPEND ls_chars TO lt_characteristic .
BREAK-POINT .

CALL FUNCTION 'BAPI_OBJCL_CREATE'
  EXPORTING
    objectkeynew   = objectkeynew
    objecttablenew = objecttablenew
    classnumnew    = classnumnew
    classtypenew   = classtypenew
  TABLES
    allocvaluesnum = lt_characteristic
*   allocvalueschar = lt_charact
*   ALLOCVALUESCURR =
    return         = lt_return.


CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
 EXPORTING
   WAIT          = 'X'
* IMPORTING
*   RETURN        =
          .
