*&---------------------------------------------------------------------*
*& Report ZTEST_BP_CREATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_bp_creation.

DATA:centraldata             LIKE  bapibus1006_central,
     centraldataorganization LIKE  bapibus1006_central_organ,
     centraldataoperson      LIKE  bapibus1006_central_person,
     addressdata             LIKE  bapibus1006_address,
     roles                   TYPE TABLE OF bapibusisb990_bproles WITH HEADER LINE,
     msg                     TYPE string,
     return                  TYPE TABLE OF    bapiret2 WITH HEADER LINE,
     telephone               TYPE TABLE OF bapiadtel WITH HEADER LINE,
     fax                     TYPE TABLE OF bapiadfax WITH HEADER LINE.

DATA businesspartner TYPE bapibus1006_head-bpartner .

"" refresh the buffer
CALL FUNCTION 'BUFFER_REFRESH_ALL'.

"" add org name
centraldataorganization-name1 = 'Test Company' .

"" BP Roles
roles-partnerrole = 'FLCU01' .
roles-valid_from = sy-datum .
roles-valid_to = '99991231' .
APPEND roles .

roles-partnerrole = 'FLCU00' .
roles-valid_from = sy-datum .
roles-valid_to = '99991231' .
APPEND roles .

""" address data
addressdata-country      = 'SA'.
addressdata-time_zone    = 'UTC+3'.
addressdata-postl_cod1   = '98765-1230'.
addressdata-street       = '#### ### ## ### ######'.
addressdata-house_no     = '30'.
addressdata-city         = 'AL Qassem'.
addressdata-langu        = 'AR'.
addressdata-transpzone   = 'QA000001'.
addressdata-region       = '045'.

""" central data
centraldata-searchterm1 = '15000551'.
centraldata-searchterm2 = '15000552'.
centraldata-title_key   = '0003'.

""" telephone data
telephone-telephone = '01090744601'.
APPEND telephone.

""" fax data """"""""
fax-fax = '12345'.
APPEND fax  .

BREAK-POINT .
CALL FUNCTION 'BAPI_BUPA_FS_CREATE_FROM_DATA2'
  EXPORTING
    partnercategory         = '2'
    partnergroup            = 'Z001'
    centraldata             = centraldata
    centraldataorganization = centraldataorganization
    addressdata             = addressdata
  IMPORTING
    businesspartner         = businesspartner
  TABLES
    telefondata             = telephone
    faxdata                 = fax
    return                  = return
    roles                   = roles.


""""""""" maintain bp -> customer """""""
IF businesspartner IS NOT INITIAL .
  COMMIT WORK AND WAIT .

  DATA :es_error TYPE cvis_message .

  cmd_ei_api=>initialize( ).
  CALL METHOD cmd_ei_api=>lock
    EXPORTING
      iv_kunnr     = businesspartner
      iv_mode_kna1 = 'E'
      iv_mandt     = sy-mandt
      iv_collect   = ' '
      iv_wait      = space
      iv_scope     = '2'
      iv_x_kunnr   = space
    IMPORTING
      es_error     = es_error.

  COMMIT WORK AND WAIT.

  DATA : is_master_data           TYPE  cmds_ei_main,
         es_master_data_correct   TYPE  cmds_ei_main,
         es_message_correct       TYPE  cvis_message,
         es_master_data_defective TYPE cmds_ei_main,
         es_message_defective     TYPE cvis_message.

  DATA :lt_customers          TYPE cmds_ei_extern_t,
        ls_customer           TYPE cmds_ei_extern,
        ls_sales_data         TYPE cmds_ei_cmd_sales,
        lt_sales              TYPE cmds_ei_sales_t,
        ls_sales              TYPE cmds_ei_sales,
        ls_data               TYPE cmds_ei_sales_data,
        ls_datax              TYPE cmds_ei_sales_datax,
        ls_cmd_central_data   TYPE cmds_ei_central_data,
        ls_cmd_central        TYPE cmds_ei_cmd_central,
        ls_vmd_central_data   TYPE cmds_ei_vmd_central_data,
        ls_vmd_central_data_x TYPE cmds_ei_vmd_central_data_xflag,
        lt_functions          TYPE cmds_ei_functions_t,
        ls_function           TYPE cmds_ei_functions,
        ls_postal             TYPE cvis_ei_1vl,
        ls_postal_data        TYPE bapiad1vl,
        ls_postal_datax       TYPE bapiad1vlx,
        ls_address            TYPE cvis_ei_address1.


  ls_customer-header-object_instance-kunnr = businesspartner..
  ls_customer-header-object_task  = 'M'.
  ls_sales_data-current_state = 'X'.


  """" main sales data
  """" bulk order
  ls_sales-task = 'M' .
  ls_sales-data_key-vkorg = '2000'.
  ls_sales-data_key-vtweg = '20'.
  ls_sales-data_key-spart = '10'.

  ls_data-bzirk = '000001'.
  ls_data-waers = 'SAR'.
  ls_data-kalks = '1'.
  ls_data-vsbed = '01' .
  ls_data-zterm = '0001'.
  ls_data-versg = '1'.
  ls_data-kdgrp = '30'.

  ls_datax-bzirk = 'X'.
  ls_datax-waers = 'X'.
  ls_datax-kalks = 'X'.
  ls_datax-vsbed = 'X'.
  ls_datax-zterm = 'X'.
  ls_datax-versg = 'X'.
  ls_datax-kdgrp = 'X'.

  ls_sales-data  = ls_data .
  ls_sales-datax = ls_datax .

  """ add partner functions""""""
  ls_function-task = 'M'.
  ls_function-data_key-parvw = 'AG'.
  ls_function-data_key-parza = '001'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_function-data_key-parvw = 'RE'.
  ls_function-data_key-parza = '002'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_function-data_key-parvw = 'RG'.
  ls_function-data_key-parza = '003'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_function-data_key-parvw = 'WE'.
  ls_function-data_key-parza = '004'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_sales-functions-functions = lt_functions[].
  APPEND ls_sales TO ls_sales_data-sales .

  "" sales data - packed order
  ls_sales-task = 'M' .
  ls_sales-data_key-vkorg = '2000'.
  ls_sales-data_key-vtweg = '20'.
  ls_sales-data_key-spart = '20'.

  ls_data-bzirk = '000001'.
  ls_data-waers = 'SAR'.
  ls_data-kalks = '1'.
  ls_data-vsbed = '01' .
  ls_data-zterm = '0001'.
  ls_data-versg = '1'.
  ls_data-kdgrp = '30'.

  ls_datax-bzirk = 'X'.
  ls_datax-waers = 'X'.
  ls_datax-kalks = 'X'.
  ls_datax-vsbed = 'X'.
  ls_datax-zterm = 'X'.
  ls_datax-versg = 'X'.
  ls_datax-kdgrp = 'X'.

  ls_sales-data  = ls_data .
  ls_sales-datax = ls_datax .

free lt_functions .
  """ add partner functions""""""
  ls_function-task = 'M'.
  ls_function-data_key-parvw = 'AG'.
  ls_function-data_key-parza = '001'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_function-data_key-parvw = 'RE'.
  ls_function-data_key-parza = '002'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_function-data_key-parvw = 'RG'.
  ls_function-data_key-parza = '003'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_function-data_key-parvw = 'WE'.
  ls_function-data_key-parza = '004'.
  ls_function-data-defpa     =  'X'.
  ls_function-data-partner   = businesspartner.
  APPEND ls_function TO lt_functions.

  ls_sales-functions-functions = lt_functions[].
  APPEND ls_sales TO ls_sales_data-sales .

  ls_customer-sales_data = ls_sales_data.

  APPEND ls_customer TO lt_customers.
  is_master_data-customers = lt_customers[].

  BREAK-POINT .
  """" maintain customer ""
  CALL METHOD cmd_ei_api=>maintain_bapi
    EXPORTING
      iv_collect_messages      = 'X'
      is_master_data           = is_master_data
    IMPORTING
      es_master_data_correct   = es_master_data_correct
      es_message_correct       = es_message_correct
      es_master_data_defective = es_master_data_defective
      es_message_defective     = es_message_defective.

  COMMIT WORK AND WAIT.
  CLEAR es_error .

  CALL METHOD cmd_ei_api=>unlock
    EXPORTING
      iv_kunnr     = businesspartner
      iv_mode_kna1 = 'E'
      iv_mandt     = sy-mandt
      iv_x_kunnr   = space
      iv_scope     = '3'
      iv_synchron  = space
      iv_collect   = ' '
    IMPORTING
      es_error     = es_error.
  COMMIT WORK AND WAIT.



  WRITE businesspartner .

ENDIF .
