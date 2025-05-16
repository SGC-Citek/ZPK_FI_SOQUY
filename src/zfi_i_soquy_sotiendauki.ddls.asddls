@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Tính số tiền đầu kì'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_SOQUY_SOTIENDAUKI as select distinct from I_JournalEntryItem as tinhTien
{
    key tinhTien.CompanyCode,
    key tinhTien.GLAccount,
    key tinhTien.FiscalYear,
   @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
   sum(tinhTien.AmountInCompanyCodeCurrency
        ) as SumAmountInCompanyCodeCurrency,
   tinhTien.CompanyCodeCurrency
  // tinhTien.CompanyCodeCurrency
} group by CompanyCode, GLAccount,FiscalYear ,CompanyCodeCurrency
