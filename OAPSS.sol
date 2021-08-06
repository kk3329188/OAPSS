contract OAPSSContract{
     string public SystemMessage;
     int public SuggestPrice;
    int CurrentHighestPrice;
    int public CurrentFinalPrice;
    int public index=0;
     int public FinalPrice=14;
    address CurrentWinner;
    address public Winner;
    bool AuctionStarting=false;
    int day1;
    int day2;
    int day3;
    int day4;
    struct ProductHighestPriceStruct{
        string ProductName;
        int day1;
        int day2;
        int day3;
        int day4;
    }
    struct Seller{
        address SellerAddr;                                   //賣家位址
        string ProductName;                                   //賣家上架商品
        
    }
    struct  Product{
        address SellerAddr;
        string ProductName;                                   //商品名稱
        string ProductInformation;                            //商品資訊
        int  LowPrice;                                        //底價
        int  EachBid;                                         //每標金額
        int Deadline;                                         //拍賣結束時間
    }
    struct Bidder{
        address BidderAddr;                                   //買家位址
        int BidPrice;                                         //出價金額
        bool GetPriceSuggestionAccess;                        //價格推薦權限
    }
    struct AuctionManager{
        address AuctionManagerAddr;                           //拍賣管理人位址
    }
//---------------------------------------------------------------------------      
    //角色mapping
    mapping(address => Seller) SellerList;  
    mapping(string => Product) ProductList;
    mapping(address => Bidder) BidderList;
    mapping (address => AuctionManager) AuctionManagerList;
    mapping(string => ProductHighestPriceStruct) ProductHighestPriceStructList;  
    
//---------------------------------------------------------------------------
    constructor ()public{                                       //初始建立
        AuctionManagerList[msg.sender]= AuctionManager(msg.sender);
        
        
    }
//---------------------------------------------------------------------------      
//角色註冊

    function SellerRegister() public{
        SellerList[msg.sender]=Seller(msg.sender,"No Product");
    }
    function BidderRegister() public{
        BidderList[msg.sender]=Bidder(msg.sender,0,false);
    }
//---------------------------------------------------------------------------     
    modifier OnlySeller{
        require(msg.sender == SellerList[msg.sender].SellerAddr);
        _;
    }
    function ApplyProduct(string memory ProductName, string memory ProductInformation,int LowPrice,int EachBid,int Deadline)public OnlySeller{
        ProductList[ProductName]=Product(msg.sender,ProductName,ProductInformation,LowPrice,EachBid,Deadline);
        SellerList[msg.sender] = Seller(msg.sender,ProductName);
        SystemMessage="Wait for Verified";
        VerifiedInformation(msg.sender);
    }
//---------------------------------------------------------------------------   

    function VerifiedInformation(address SellerAddr)public{
        if (ProductList[SellerList[SellerAddr].ProductName].Deadline<=0){
            SystemMessage="ApplyProduct Fail because of Deadline";
        }
        else if(utilCompareInternal(ProductList[SellerList[SellerAddr].ProductName].ProductInformation,"")){
            SystemMessage="ApplyProduct Fail because of ProductInformation";
        }
        else if(ProductList[SellerList[SellerAddr].ProductName].LowPrice <=0){
            SystemMessage="ApplyProduct Fail because of LowPrice";
        }
        else if(utilCompareInternal(SellerList[SellerAddr].ProductName,"")==true){
            SystemMessage="ApplyProduct Fail because of ProductName";
        }
        else{
            SystemMessage="ApplyProduct Success";
        }
    }
//---------------------------------------------------------------------------      
    //申請價格推薦   
    modifier OnlyBidder{
        require(msg.sender == BidderList[msg.sender].BidderAddr);
        require(BidderList[msg.sender].GetPriceSuggestionAccess==true);
        _;
    }
    function ChangeToSuggestionBidder(address payable to,int money) public  payable{
        if (money == 1 ){
            if(AuctionStarting == false){
                BidderList[msg.sender].GetPriceSuggestionAccess= true;    
                pay(to,money);   
                SystemMessage="change to Suggestion Bidder is success";
               // SuggestPrice = RequestToPriceSuggest(ProductName);
            }
            else{
                SystemMessage="change to Suggestion Bidder is Fail because of auction is not starting";
            }
        }
        else {
        SystemMessage="change to Suggestion Bidder is Fail";
        }
        
    } 

    function RequestToPriceSuggest(string memory ProductName)public OnlyBidder  payable{
        
     
        int deltaX;
        int deltaY;
        int deltaZ;
        
        day4= ProductHighestPriceStructList[ProductName].day4;
        day3= ProductHighestPriceStructList[ProductName].day3;
        day2= ProductHighestPriceStructList[ProductName].day2;
        day1= ProductHighestPriceStructList[ProductName].day1;
        //---------test data
        day4=14;
        day3=13;
        day2= 10;
        day1= 11;
        //---------
        deltaX=day2-day1;
        deltaY=day3-day2;
        deltaZ=day4-day1;
        SuggestPrice=day4+(day1*(deltaX*100/((day1+day4)/2))+day2*(deltaY*100/((day2+day1)/2))+day3*(deltaZ*100/((day2+day3)/2)))/3/100;
        
    }
    
    
//---------------------------------------------------------------------------  
    modifier OnlyAuctionManager{
        require(msg.sender == AuctionManagerList[msg.sender].AuctionManagerAddr);
        _;
    }
//啟動拍賣       
    function ActiveAuction(string memory ProductName)public OnlyAuctionManager{
        AuctionStarting=true;
        //EndAuctionTime=ProductList[ProductName].Deadline;
        SystemMessage="Auction Start";
    }
    
//---------------------------------------------------------------------------      
    //投標者出價
    modifier OnlyBidderStartBid{
        require(msg.sender == BidderList[msg.sender].BidderAddr);
        require(AuctionStarting==true);
        _;
    }
    function RequestToBid(int BidPrice,string memory ProductName)public OnlyBidderStartBid{
        
        if (BidPrice >= ProductList[ProductName].LowPrice){
            if (BidPrice > CurrentHighestPrice){
                
                   // bidcount = bidcount + 1; 
                    BidderList[msg.sender].BidPrice=BidPrice;
                    CurrentHighestPrice=BidPrice;
                    if(CurrentFinalPrice==0){
                       CurrentFinalPrice = ProductList[ProductName].LowPrice + ProductList[ProductName].EachBid;
                       CurrentWinner=msg.sender;
                       CurrentHighestPrice = BidPrice;
                    }
                    else{
                        if(BidPrice > CurrentHighestPrice){
                              CurrentFinalPrice = CurrentFinalPrice + ProductList[ProductName].EachBid;
                              CurrentWinner=msg.sender;
                              CurrentHighestPrice = BidPrice;
                        }
                        else{
                              CurrentFinalPrice = BidPrice + ProductList[ProductName].EachBid;
                              CurrentWinner=msg.sender;
                        }
                       
                    }
                    SystemMessage="Bid Success";
            }
            else{
                SystemMessage="Bid Fail by currentprice";
            }
        }
        else{
            SystemMessage="Bid Fail by low price";
        }
    }
//---------------------------------------------------------------------------      
    //公布得標價  
    function AnnoucementWinner(address SellerAddr ,string memory ProductName)public OnlyAuctionManager{
             
             
             Winner=CurrentWinner;
             FinalPrice=CurrentFinalPrice;
             ProductHighestPriceStructList[ProductName].day1= ProductHighestPriceStructList[ProductName].day2;
             ProductHighestPriceStructList[ProductName].day2=ProductHighestPriceStructList[ProductName].day3;
             ProductHighestPriceStructList[ProductName].day3=ProductHighestPriceStructList[ProductName].day4;
             ProductHighestPriceStructList[ProductName].day4=FinalPrice;
             SystemMessage="Aucton End";
             AuctionStarting=false;
             //bidcount=1;
            
    }
    
     modifier OnlyWinner{
        require(msg.sender == Winner);
        _;
    }
    
    function WinnerPayment(address payable SellerAddr ,string memory ProductName, int money)public OnlyWinner payable{
        if (utilCompareInternal(ProductList[ProductName].ProductName,ProductName)){
            if (money == FinalPrice){
                if(SellerAddr==ProductList[ProductName].SellerAddr){
                    transfermoney(SellerAddr,money);
                    SystemMessage="payment Success";
                }
                else{
                    SystemMessage="SellerAddr is not correct";
                }
            }
            else
            {
                SystemMessage="Money is not correct";
            }
        }
        else{
            SystemMessage="Product is not correct";
        }
    }
//---------------------------------------------------------------------------      
    //轉帳     
    
    function pay(address payable to,int money) public payable{            
            transfermoney(to,money);                       
            
           
    }
    function  transfermoney(address payable to,int tokens) private {                                
            to.transfer(uint(tokens) * 1 ether );
     }
//---------------------------------------------------------------------------      
    //字串處理   
    
    function strConcat( string memory _a,  string memory _b) internal returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
   }  
   function utilCompareInternal(string memory a, string memory b) internal returns (bool) {
        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        for (uint i = 0; i < bytes(a).length; i ++) {
            if(bytes(a)[i] != bytes(b)[i]) {
            return false;
            }
        }
        return true;
    }
    
}
    