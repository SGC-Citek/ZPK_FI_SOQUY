@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Lấy số chứng từ thu chi'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_SOQUY_CHUNGTU_THU_CHI
  as select distinct from I_JournalEntryItem as chithu
    
left outer join            I_OperationalAcctgDocItem          as OperationalAcctgDocItem         on  chithu.CompanyCode             = OperationalAcctgDocItem.CompanyCode
                                                                                                 and chithu.FiscalYear              = OperationalAcctgDocItem.FiscalYear
                                                                                                 and chithu.AccountingDocument      = OperationalAcctgDocItem.AccountingDocument
                                                                                                 and chithu.LedgerGLLineItem  = cast(OperationalAcctgDocItem.AccountingDocumentItem as abap.char( 6 ))
{
  key chithu.CompanyCode,
  key chithu.FiscalYear,
  key chithu.AccountingDocument,
//  key chithu.AccountingDocumentItem,
    key chithu.LedgerGLLineItem as AccountingDocumentItem,
      chithu.DebitCreditCode,
      chithu.IsReversal,
      case
          when chithu.Customer <> ''
              then chithu.Customer
          else chithu.Supplier
      end   as Account,
      chithu.Supplier,
      chithu.Customer,
      chithu._Supplier,
      chithu._Customer,
      OperationalAcctgDocItem.AddressAndBankIsSetManually,
      case
            when chithu.FinancialAccountType = 'K' or chithu.FinancialAccountType = 'D'
                then case
                 when chithu.DebitCreditCode = 'H' and chithu.IsReversal = ''
                    then chithu.AccountingDocument
                when chithu.DebitCreditCode = 'H' and chithu.IsReversal = 'X'
                    then chithu.AccountingDocument
                end
           when chithu.FinancialAccountType = 'S' and (chithu.GLAccount like '111%' or chithu.GLAccount like '112%' )
                then case
                when chithu.DebitCreditCode = 'S' and chithu.IsReversal = ''
                    then chithu.AccountingDocument
                when chithu.DebitCreditCode = 'S' and chithu.IsReversal = 'X'
                    then chithu.AccountingDocument
                end 
           else  
            case
                when chithu.DebitCreditCode = 'H' and chithu.IsReversal = ''
                    then chithu.AccountingDocument
                when chithu.DebitCreditCode = 'H' and chithu.IsReversal = 'X'
                    then chithu.AccountingDocument
                end 
        end as SoChungTuThu,
      case
          when chithu.FinancialAccountType = 'K' or chithu.FinancialAccountType = 'D'
              then case
               when chithu.DebitCreditCode = 'S' and chithu.IsReversal = ''
                  then chithu.AccountingDocument
              when chithu.DebitCreditCode = 'S' and chithu.IsReversal = 'X'
                  then chithu.AccountingDocument
              end 
               when chithu.FinancialAccountType = 'S' and (chithu.GLAccount like '111%' or chithu.GLAccount like '112%' )
                    then case
                    when chithu.DebitCreditCode = 'H' and chithu.IsReversal = ''
                        then chithu.AccountingDocument
                    when chithu.DebitCreditCode = 'H' and chithu.IsReversal = 'X'
                        then chithu.AccountingDocument
                    end 
           else  
            case
                when chithu.DebitCreditCode = 'S' and chithu.IsReversal = ''
                    then chithu.AccountingDocument
                when chithu.DebitCreditCode = 'S' and chithu.IsReversal = 'X'
                    then chithu.AccountingDocument
                end 
      end   as SoChungTuChi
} 
//where (chithu.GLAccount like '111%' or chithu.GLAccount like '112%' )
//    and (chithu.DebitCreditCode = 'S' or chithu.DebitCreditCode = 'H')
//    and (OperationalAcctgDocItem.IsNegativePosting = '' or OperationalAcctgDocItem.IsNegativePosting = 'X')
