**環境設定**
1. 利用RemixIDE開啟該檔案 
2. Solidty version使用 0.6.6
3. 可直接使用JVM部屬及調用(請選擇Berlin)	
4. Gas limit 調整至60000000

**功能使用**
1. 本系統根據拍賣流程分別調用功能
2. 依照下方功能表順序依次調用

## 功能調用及順序

| 功能名稱   | 智慧合約演算法 |
| ------------- |:-------------:|
| 部屬合約      | Deploy()     |
| 賣家註冊      | SellerRegister()     |
| 買家註冊      | BidderRegister()     |
| 申請商品上架   | VerifiedProductInformation()     |
| 商品驗證        | VerifiedProductInformation    |
| 買家申請更動身分  | ChangeToPriceSuggest()     |
| 請求價格推薦    | RequestToPriceSuggest()   |
| 啟動拍賣程序     | ActiveAuction     |
| 請求出價   | RequestBid     |
| 公布得標者   | AnnoucementWinner     |
| 得標者付款   | WinnerPayment()     |

