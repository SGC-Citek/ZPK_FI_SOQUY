@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Lấy sổ quỹ tiền VND'
define  view entity ZFI_I_SOQUY_SOTIENDAUKI_VND
with parameters
@Environment.systemField:#SYSTEM_DATE
                FromDate: vdm_v_key_date
as select distinct from I_OperationalAcctgDocItem as tinhTien

{
    key tinhTien.CompanyCode,
    key tinhTien.GLAccount,
    //key tinhTien.FiscalYear,
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    case when tinhTien.CompanyCodeCurrency <> 'VND' //tinhTien.TransactionCurrency <> 'VND'
        then sum(tinhTien.AmountInCompanyCodeCurrency
        )*100
        else
        sum(tinhTien.AmountInCompanyCodeCurrency
        )
    end as SumAmountInCompanyCodeCurrency,
   tinhTien.CompanyCodeCurrency
}where(tinhTien.PostingDate < $parameters.FromDate)group by CompanyCode, GLAccount ,CompanyCodeCurrency //, TransactionCurrency
