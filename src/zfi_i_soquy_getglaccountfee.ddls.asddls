@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Đánh dấu chứng  từ có glaccount chi phí'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_SOQUY_GETGLACCOUNTFEE as select distinct from I_JournalEntryItem as jei
{
    key jei.AccountingDocument,
    key jei.CompanyCode,
    key jei.FiscalYear,
    key jei.LedgerGLLineItem as AccountingDocumentItem,
    case when jei.GLAccount like '0064170106' or jei.GLAccount like '0064250104'
        then 'X'
        else ''
    end as MarkFee
}
