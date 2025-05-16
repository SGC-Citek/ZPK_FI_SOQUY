@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Lấy số chứng từ thu chi'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_SOQUY_CTU_THUCHI 
    as select from I_OperationalAcctgDocItem
{
    key CompanyCode,
    key AccountingDocument,
    key FiscalYear,
    key AccountingDocumentItem,
    
    GLAccount,
    DocumentItemText,
    
    TransactionCurrency,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    AmountInTransactionCurrency,
    
    CompanyCodeCurrency,
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    AmountInCompanyCodeCurrency,
    
    FinancialAccountType,
    
    DebitCreditCode,
    IsNegativePosting,
    
    case
          when Customer <> ''
              then Customer
          else Supplier
    end   as Account,
    
    Supplier,
    Customer,
    AddressAndBankIsSetManually,
    
    case when DebitCreditCode = 'S'
         then AccountingDocument
    end as SoChungTuThu,
    
    case when DebitCreditCode = 'H'
         then AccountingDocument
    end as SoChungTuChi
   
    
} where ( DebitCreditCode = 'S' or DebitCreditCode = 'H' )
    and ( IsNegativePosting = '' or IsNegativePosting = 'X')
    and ( GLAccount like '111%' or GLAccount like '112%' )
