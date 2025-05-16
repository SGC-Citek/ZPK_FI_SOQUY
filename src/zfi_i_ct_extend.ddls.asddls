@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Những chứng từ có tồn đầu kỳ nhưng ko phát sinh trong kỳ'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZFI_I_CT_EXTEND
  with parameters
    FromDate          : vdm_v_key_date,
    IsIncludeReversed : zde_boolean

  as select from I_JournalEntryItem as jei
    inner join   I_JournalEntry     as je on  je.CompanyCode        =    jei.CompanyCode
                                          and je.FiscalYear         =    jei.FiscalYear
                                          and je.AccountingDocument =    jei.AccountingDocument
                                          and (
                                             jei.GLAccount          like '111%'
                                             or jei.GLAccount       like '112%'
                                           )
                                          and jei.Ledger            like '0L'
  //                                                                                                          and (
  //                                                                                                             $parameters.IsIncludeReversed   is not initial
  //                                                                                                             or(
  //                                                                                                               $parameters.IsIncludeReversed is initial
  //                                                                                                               and(
  //                                                                                                                 je.IsReversal               is initial
  //                                                                                                                 or je.IsReversal            is null
  //                                                                                                               )
  //                                                                                                               and(
  //                                                                                                                 je.IsReversed               is initial
  //                                                                                                                 or je.IsReversed            is null
  //                                                                                                               )
  //                                                                                                             )
  //                                                                                                           )
{
  key jei.CompanyCode,
  key jei.AccountingDocument
}
where
           $parameters.FromDate            = jei.PostingDate
  and      jei.AmountInCompanyCodeCurrency > 0
  and(
           $parameters.IsIncludeReversed   is not initial
    or(
           $parameters.IsIncludeReversed   is initial
      and(
           je.IsReversal                   is initial
        or je.IsReversal                   is null
      )
      and(
           je.IsReversed                   is initial
        or je.IsReversed                   is null
      )
    )
  )
