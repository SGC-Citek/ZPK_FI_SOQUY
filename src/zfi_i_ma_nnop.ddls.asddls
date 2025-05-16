@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Mã người nhận nộp'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_MA_NNOP 
    as select from I_OperationalAcctgDocItem as OADI
       left outer join    I_GLAccountLineItem       as GlaItem on GlaItem.CompanyCode        = OADI.CompanyCode
                                                              and GlaItem.AccountingDocument = OADI.AccountingDocument
                                                              and GlaItem.FiscalYear         = OADI.FiscalYear
                                                              and GlaItem.AccountingDocumentItem = OADI.AccountingDocumentItem
{
  key OADI.CompanyCode,
  key OADI.AccountingDocument,
  key OADI.FiscalYear,
  key GlaItem.OffsettingLedgerGLLineItem,
  
  case when OADI.AlternativePayeePayer <> ''
       then OADI.AlternativePayeePayer
       when OADI.FinancialAccountType  =  'K'
       then OADI.Supplier
       when OADI.FinancialAccountType  =  'D'
       then OADI.Customer
  end as ma
  
} where OADI.FinancialAccountType  =  'K'
     or OADI.FinancialAccountType  =  'D'
