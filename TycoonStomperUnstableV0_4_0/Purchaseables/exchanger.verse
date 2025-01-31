using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using {cc}
purchaseable_exchanger<public>:=class<concrete><final>(fxpurchaseable):


    var Ptype <override> :  PurchaseableType = PurchaseableType.Exchanger
    @editable var exchangeableConfig : unique_exchanger_buyable = unique_exchanger_buyable{}
    


    Initialize<override>(Hostess:base, I:int):void=    
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)


        
        #Lists out all the properties of the item
        Detail("Exchanger")
        exchangeableConfig.ExchangeBillboard.Initialize(Self)
        

 
    OnRebirth<override>():void=
        (super:)OnRebirth()

    GetStringParams<override>(P:?player)<transacts>:[string]string=
        var default : [string]string = (super:)GetStringParams(P)
        if:
            Owner := MaybeOwner?
            FromCur:=GetCurrencyConfig[Owner, exchangeableConfig.FromCurrencyID]
            ToCur:=GetCurrencyConfig[Owner, exchangeableConfig.ToCurrencyID]
        then:
            FromCurrencyName := FromCur.Name
            ToCurrencyName := ToCur.Name
            set default = MergeStringMaps(default, map{
                "[FromCurrencyName]" => "{FromCurrencyName}",
                "[ToCurrencyName]" => "{ToCurrencyName}"
            })
        else:
            GlobalSuperlog("Failed to fetch echange currency names Err 0410")

        set default = MergeStringMaps(default, map{
                    "[FromCurrencyID]" => "{exchangeableConfig.FromCurrencyID}",
                    "[ToCurrencyID]" => "{exchangeableConfig.ToCurrencyID}",
                    "[ExchangeRate]" => "{DecimalTrunc(exchangeableConfig.ExchangeRate, exchangeableConfig.ExchangeRateDecimalPercision)}"
                })

        return default


    #Host the Shoot
    Host<override>()<suspends>:void=if. Owner := MaybeOwner? then. exchangeableConfig.Initialize(Owner)
         
    

unique_exchanger_buyable:=class(Inaugurable):

    @editable{ToolTip:=FromCurrencyTT} var FromCurrencyID: int = 0
    @editable{ToolTip:=ToCurrencyTT} var ToCurrencyID  : int = 0
    @editable{ToolTip:=ExchangeRateTT} var ExchangeRate  : float = 1.0
    @editable var ExchangeRateDecimalPercision : int = 2
    @editable var ExchangeBillboard : billboard_main = billboard_main
    {
        BillboardText  :=   "Convert [FromCurrencyName] to [ToCurrencyName] \n rate is [ExchangeRate]"
    }
    @editable var ExchangeZone : anyzone_or_atm = anyzone_or_atm{}


    Initialize<override>(Base:base):void=
        ExchangeZone.Initialize(Base, false)
        spawn. AwaitExchangeAttempt(Base)

    AwaitExchangeAttempt(Base:base)<suspends>:void=
        loop:
            Agent := ExchangeZone.PlayerEntersEvent.Await();
            if:
                Player := player[Agent]
                Base.Players.Find[Player]
                Stats := GetCoreStats[Player, Base.Base_Setup.PersistenceCore]
                FromCurrencyAmount := Stats.AssociatedCurrencies[FromCurrencyID]
                GrantAmount := Ceil[FromCurrencyAmount*ExchangeRate]
            then:
                RemoveMoney(Base, Player, FromCurrencyID, FromCurrencyAmount)
                GrantMoney(Base, Player, ToCurrencyID, GrantAmount, true)
            else:
                GlobalSuperlog("Failed to exchange Err 0411")

    