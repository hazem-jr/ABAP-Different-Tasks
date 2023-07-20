*&---------------------------------------------------------------------*
*& Report ZFI_VENDOR_AGING
*&---------------------------------------------------------------------*
REPORT zfi_vendor_aging.
TABLES :  acdoca  .
SELECTION-SCREEN : BEGIN OF BLOCK b WITH FRAME TITLE TEXT-001  .
SELECT-OPTIONS : s_lifnr FOR acdoca-lifnr ,
                 s_bukrs FOR acdoca-rbukrs,
                 s_umskz FOR acdoca-umskz .
PARAMETERS       p_date  TYPE acdoca-budat OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b  .

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002  .
SELECTION-SCREEN BEGIN OF LINE.

PARAMETERS : p1 TYPE int2 OBLIGATORY,
             p2 TYPE int2,
             p3 TYPE int2,
             p4 TYPE int2,
             p5 TYPE int2.

DATA : date1 TYPE budat,  date2 TYPE budat,
       date3 TYPE budat, date4 TYPE budat,
       date5 TYPE budat.

DATA : lt_fcat TYPE slis_t_fieldcat_alv,
       ls_fcat TYPE slis_fieldcat_alv,
       lt_sort TYPE slis_t_sortinfo_alv,
       ls_sort TYPE slis_sortinfo_alv.

DATA : least_date TYPE budat  .

DATA: st_layout TYPE slis_layout_alv .
st_layout-colwidth_optimize = 'X'.
st_layout-zebra = 'X' .
SELECTION-SCREEN END OF LINE  .
SELECTION-SCREEN END OF BLOCK b1  .

TYPES : BEGIN OF str_alv ,
          lifnr       TYPE acdoca-lifnr,
          name1       TYPE lfa1-name1,
          belnr       TYPE acdoca-belnr,
          budat       TYPE acdoca-budat,
          bldat       TYPE acdoca-bldat,
          bttype      TYPE acdoca-bttype,
          bttext      TYPE text30,
          umskz       TYPE acdoca-umskz,
*period 1
          period1(20) ,
          wsl1_d      TYPE  acdoca-wsl ,      " debit in transaction currency
          wsl1_c      TYPE  acdoca-wsl ,      " credit in transaction currency
          net_w1      TYPE  acdoca-wsl ,      " net amount in ransaction currency
          hsl1_d      TYPE  acdoca-hsl ,      " debit in company currency
          hsl1_c      TYPE  acdoca-hsl ,      " credit in company currency
          net_h1      TYPE  acdoca-hsl ,      " net amount in company currency
          rwcur1      TYPE  acdoca-rwcur ,    " transaction currency
          rhcur1      TYPE  acdoca-rhcur ,    " company currency
*period 2
          period2(20) ,
          wsl2_d      TYPE  acdoca-wsl,
          wsl2_c      TYPE  acdoca-wsl,
          net_w2      TYPE  acdoca-wsl,
          hsl2_d      TYPE  acdoca-hsl,
          hsl2_c      TYPE  acdoca-hsl,
          net_h2      TYPE  acdoca-hsl,
          rwcur2      TYPE  acdoca-rwcur,
          rhcur2      TYPE  acdoca-rhcur,
*period 3
          period3(20) ,
          wsl3_d      TYPE  acdoca-wsl,
          wsl3_c      TYPE  acdoca-wsl,
          net_w3      TYPE  acdoca-wsl,
          hsl3_d      TYPE  acdoca-hsl,
          hsl3_c      TYPE  acdoca-hsl,
          net_h3      TYPE  acdoca-hsl,
          rwcur3      TYPE  acdoca-rwcur,
          rhcur3      TYPE  acdoca-rhcur,
*period 4
          period4(20) ,
          wsl4_d      TYPE  acdoca-wsl,
          wsl4_c      TYPE  acdoca-wsl,
          net_w4      TYPE  acdoca-wsl,
          hsl4_d      TYPE  acdoca-hsl,
          hsl4_c      TYPE  acdoca-hsl,
          net_h4      TYPE  acdoca-hsl,
          rwcur4      TYPE  acdoca-rwcur,
          rhcur4      TYPE  acdoca-rhcur,
*period 5
          period5(20) ,
          wsl5_d      TYPE  acdoca-wsl,
          wsl5_c      TYPE  acdoca-wsl,
          net_w5      TYPE  acdoca-wsl,
          hsl5_d      TYPE  acdoca-hsl,
          hsl5_c      TYPE  acdoca-hsl,
          net_h5      TYPE  acdoca-hsl,
          rwcur5      TYPE  acdoca-rwcur,
          rhcur5      TYPE  acdoca-rhcur,

        END OF str_alv  .
DATA : lt_acdoca TYPE TABLE OF acdoca .
DATA : lt_alv TYPE TABLE OF str_alv,
       ls_alv TYPE          str_alv.

START-OF-SELECTION  .

  BREAK abapcon20  .
*& find the periods dates ..
  date1 = p_date  - p1  .
  least_date = date1    .
  IF p2 IS NOT INITIAL  .
    date2 = p_date  - p2  .
    least_date = date2    .
  ENDIF  .
  IF p3 IS NOT INITIAL   .
    date3 = p_date  - p3  .
    least_date = date3    .
  ENDIF  .
  IF p4 IS NOT INITIAL   .
    date4 = p_date  - p4  .
    least_date = date4    .
  ENDIF .
  IF p5 IS NOT INITIAL   .
    date5 = p_date  - p5  .
    least_date = date5    .
  ENDIF .
*& get all Documents from acdoca excluding reversed and cleared documents ..
  SELECT  * FROM acdoca INTO CORRESPONDING FIELDS OF TABLE lt_acdoca WHERE
          lifnr IN s_lifnr  AND rbukrs IN s_bukrs AND umskz IN s_umskz AND budat BETWEEN  least_date AND p_date
          AND xreversed NE 'X' AND koart = 'K' AND xreversing NE 'X' AND augbl = '' .
*          AND belnr NOT IN ( SELECT DISTINCT augbl FROM acdoca WHERE
*          lifnr IN s_lifnr  AND rbukrs IN s_bukrs AND umskz IN s_umskz
*          AND budat BETWEEN least_date AND p_date AND xreversed NE 'X' AND koart = 'K' AND xreversing NE 'X').

  LOOP AT lt_acdoca ASSIGNING FIELD-SYMBOL(<fs_acdoca>) .
    MOVE-CORRESPONDING <fs_acdoca> TO ls_alv  .
*& vendor name
    SELECT SINGLE name1 INTO ls_alv-name1 FROM lfa1
       WHERE lifnr = ls_alv-lifnr .
*& bussiness transaction description ..
    SELECT SINGLE txt FROM finsc_bttype_t INTO ls_alv-bttext
       WHERE bttype = ls_alv-bttype AND langu = 'EN'.

*& first period ..
    IF <fs_acdoca>-budat BETWEEN date1 AND p_date  .
      PERFORM fill_period USING <fs_acdoca>
                      CHANGING ls_alv-rwcur1 ls_alv-rhcur1
                               ls_alv-wsl1_d ls_alv-wsl1_c
                               ls_alv-hsl1_d ls_alv-hsl1_c
                               ls_alv-net_w1 ls_alv-net_h1.
    ENDIF  .

*& second period ..
    IF <fs_acdoca>-budat BETWEEN date2 AND date1.

      PERFORM fill_period USING <fs_acdoca>
                          CHANGING ls_alv-rwcur2 ls_alv-rhcur2
                                   ls_alv-wsl2_d ls_alv-wsl2_c
                                   ls_alv-hsl2_d ls_alv-hsl2_c
                                   ls_alv-net_w2 ls_alv-net_h2.
    ENDIF  .

*& third period ..
    IF <fs_acdoca>-budat BETWEEN date3 AND date2.
      PERFORM fill_period USING <fs_acdoca>
                          CHANGING ls_alv-rwcur3 ls_alv-rhcur3
                                   ls_alv-wsl3_d ls_alv-wsl3_c
                                   ls_alv-hsl3_d ls_alv-hsl3_c
                                   ls_alv-net_w3 ls_alv-net_h3.
    ENDIF  .

*& fourth period ..
    IF <fs_acdoca>-budat BETWEEN date4 AND date3.
      PERFORM fill_period USING <fs_acdoca>
                          CHANGING ls_alv-rwcur4 ls_alv-rhcur4
                                   ls_alv-wsl4_d ls_alv-wsl4_c
                                   ls_alv-hsl4_d ls_alv-hsl4_c
                                   ls_alv-net_w4 ls_alv-net_h4.
    ENDIF  .

*& fifth period ..
    IF <fs_acdoca>-budat BETWEEN date5 AND date4.
      PERFORM fill_period USING <fs_acdoca>
                          CHANGING ls_alv-rwcur5 ls_alv-rhcur5
                                   ls_alv-wsl5_d ls_alv-wsl5_c
                                   ls_alv-hsl5_d ls_alv-hsl5_c
                                   ls_alv-net_w5 ls_alv-net_h5.
    ENDIF  .

    COLLECT ls_alv INTO lt_alv .
    CLEAR ls_alv .
  ENDLOOP  .

  DELETE ADJACENT DUPLICATES FROM lt_alv  .
  SORT lt_alv BY belnr budat  .
*& build cataloge ..
  INCLUDE zbuild_cataloge .
*&---------------------------------------------------------------------*
*& Form FILL_PERIOD
*&---------------------------------------------------------------------*
FORM fill_period  USING    p_acdoca TYPE acdoca
                  CHANGING p_rwcur  TYPE acdoca-rwcur
                           p_rhcur  TYPE acdoca-rhcur
                           p_wsl_d  TYPE acdoca-wsl
                           p_wsl_c  TYPE acdoca-wsl
                           p_hsl_d  TYPE acdoca-hsl
                           p_hsl_c  TYPE acdoca-hsl
                           p_net_w  TYPE acdoca-wsl
                           p_net_h  TYPE acdoca-hsl.

  p_rwcur = p_acdoca-rwcur .
  p_rhcur = p_acdoca-rhcur .
  IF    p_acdoca-wsl > 0 .
    p_wsl_d = p_acdoca-wsl .
  ENDIF .
  IF    p_acdoca-wsl < 0 .
    p_wsl_c = p_acdoca-wsl .
  ENDIF  .
  IF    p_acdoca-hsl > 0 .
    p_hsl_d = p_acdoca-hsl .
  ENDIF  .
  IF    p_acdoca-hsl < 0 .
    p_hsl_c = p_acdoca-hsl .
  ENDIF .
*& find net amount
  p_net_w = p_wsl_d + p_wsl_c .
  p_net_h = p_hsl_d + p_hsl_c .

ENDFORM.
