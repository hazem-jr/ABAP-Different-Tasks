FUNCTION ZCREATE_IT3323_RECORD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_RECORD) TYPE  P3323
*"  EXPORTING
*"     REFERENCE(RETURN) TYPE  BAPIRETURN1
*"----------------------------------------------------------------------

*& lock the employee
 CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
       EXPORTING
            number = p_record-pernr
       IMPORTING
            return = return.


 free return .

*& create the record
   CALL FUNCTION 'HR_INFOTYPE_OPERATION'
       EXPORTING
            INFTY          = '3323'
            NUMBER         = p_record-pernr
            SUBTYPE        = p_record-subty
            VALIDITYEND    = p_record-ENDDA
            VALIDITYBEGIN  = p_record-BEGDA
            RECORD         = p_record
            OPERATION      = 'INS'
       IMPORTING
            RETURN         = return
*            KEY            = key
       EXCEPTIONS
            OTHERS         = 0.


*& unlock the employee
     CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
       EXPORTING
            number = p_record-pernr.










ENDFUNCTION.
