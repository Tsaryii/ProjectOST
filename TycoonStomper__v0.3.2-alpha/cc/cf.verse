using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}
using {Stomper}

#███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
#██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
#█████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
#██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
#██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
#╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


#Change this to true to enable the global superlog system
#The global superlog system will print all superlogs to the console
#Super logs are for almost everything so this will clutter the console
#This is useful for mass debugging purposes otherwise keep it off
UseGlobalSuperLog: logic = false

GlobalSuperlog<public>(I:string)<transacts>:void={if(UseGlobalSuperLog?){Print("{I}")}}

CreateID<public>(Length:int)<decides><transacts>:string={
        Coords:string=("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        ID := for:
            I := 0..Length
            R:=GetRandomInt(0,35)
        do{Coords[R]}; ID   
}
GlobalizedDetailing(P:purchaseable, Name:string):void=
    Print("\n == {Name} == \n {P.Name} | {P.ID}, \n Description: {P.Description}, \n Price: {P.Price}, \n CurrencyToSpendID: {P.CurrencyToSpendID}, \n CurrencyToReceiveID: {P.CurrencyToReceiveID}, \n GrantAmount: {P.GrantAmount},")
#Shows a localized message to the player using the HUD message device 
(HM:hud_message_device).StringShow<public>(Message:string, Agent:agent):void={HM.SetText(S2M(Message)); HM.Show(Agent)}

#Localizes a string to the player's language by converting the string to a message
S2M<localizes><public>(s:string)<computes>:message="{s}"




#Grant money to a player
GrantMoney<public>(Base:base, Player:player, GrantID:int, Amount:int, Bypass:logic):void=
    
        #If the player is found in the base's player list
        if:
            Base.Players.Find[Player]
            Rebirths := GetStats[Player].Rebirths
            CurrentValue := GetStats[Player].AssociatedCurrencies[GrantID]
            #Example with a rebirth multiplier of 1.5 and 100 as the base amount
            #((1.5^0) * 100) = 100
            #((1.5^1) * 100) = 150
            #((1.5^2) * 100) = 225
            #((1.5^3) * 100) = 337.5
            AmountToGrant := GetRebirthAmount[Base, Rebirths, Amount]
        then:
            Base.MoneyGranted.Signal(Player, GrantID, Amount)
            if:
                Bypass?
            then:
                UpdateAssociatedCurrencies(Player, GrantID, AmountToGrant+CurrentValue)
            else:
                #If the currency does not have the zone, then update the associated currencies instantly
                if(not HasZone[Base, GrantID]):
                    
                    UpdateAssociatedCurrencies(Player, GrantID, AmountToGrant+CurrentValue)

                
                #if the user opted to have a zone, then add the amount to the currency's claimable amount
                else if:
                    Currency := GetCurrencyConfig[Base, GrantID]
                then:
                    Currency.AddAwaitableCash(AmountToGrant)

BypassedGrantMoney<public>(Base:base, Player:player, GrantID:int, Amount:int):void=
    
    #If the player is found in the base's player list
    if:
        Base.Players.Find[Player]
        Rebirths := GetStats[Player].Rebirths
        CurrentValue := GetStats[Player].AssociatedCurrencies[GrantID]
        #Example with a rebirth multiplier of 1.5 and 100 as the base amount
        #((1.5^0) * 100) = 100
        #((1.5^1) * 100) = 150
        #((1.5^2) * 100) = 225
        #((1.5^3) * 100) = 337.5
        AmountToGrant := GetRebirthAmount[Base, Rebirths, Amount]
    then:
        UpdateAssociatedCurrencies(Player, GrantID, AmountToGrant+CurrentValue)
        Base.MoneyGranted.Signal(Player, GrantID, Amount)

        


RemoveMoney<public>(Base:base, Player:player, GrantID:int, Amount:int)<transacts>:void=
    if:
        Base.Players.Find[Player]
        CurrentValue := GetStats[Player].AssociatedCurrencies[GrantID]
    then:
        #If the currency does not have the zone, then update the associated currencies instantly
            UpdateAssociatedCurrencies(Player, GrantID, CurrentValue-Amount)

        


GetRebirthAmount<public>(Base:base, Rebirths:int, Amount:int)<decides><transacts>:int=
    return Round[(Pow(Base.Base_Setup.RebirthCashMultiplier, Rebirths*1.0) * Amount)]

GrantXP<public>(Base:base, Player:player, Amount:int)<transacts>:void={}
    
condition<public>:=struct<concrete>():
    @editable MinCurrencyAmount: int = 0
    @editable MinPlayerExperience: int = 0

GetConveyorConfig<public>(Base:base, ID:int)<decides><transacts>:unique_conveyor=
    {
        Prim := for:
            I -> C:Base.Conveyors
            I = ID
        do:
            C.ConveyorConfig
        Prim[0]
    }
#Returns the currency config of a bases currency ID
GetCurrencyConfig(Base:base, CurrencyID:int)<decides><transacts>:currency_config=
    {
        Prim := for:
            I -> C:Base.Currencies
            I = CurrencyID
        do:
            C
        Prim[0]
    }

MeetsConditions<public>(Condition:condition, Player:player, CurrencyID:int)<decides><transacts>:void=
        Stats := GetStats[Player]
        Money := Stats.AssociatedCurrencies[CurrencyID]
        Experience := Stats.Experience

        Money >= Condition.MinCurrencyAmount
        Experience >= Condition.MinPlayerExperience
        return
        


#Returns the currency ID of a base specific currency config
GetCurrencyID<public>(Base:base, Currency:currency_config)<decides><transacts>:int=
    {
        Prim := for:
            I -> C:Base.Currencies
            C = Currency
        do:
            I
        Prim[0]
    }


#Checks if a currency has a zone
HasZone(Base:base, ID:int)<decides><transacts>:void=
    {
        Currency := GetCurrencyConfig[Base, ID]
        Currency.MaybeCollectionZone?
        return
        
    }

Load<public>(B:base, Purchaseable:PurchaseableType, I:int):void=
    if(Player := B.Players[0]):
        case(Purchaseable):
            PurchaseableType.Undefined =>{}

            PurchaseableType.BasicProp       =>         if(BasicPropItem := B.BasicProps[I]){BasicPropItem.Load(Player)}
            
            PurchaseableType.NPCBuyable      =>         if(NPCBuyableItem := B.NPCSpawners[I]){NPCBuyableItem.Load(Player)}

            PurchaseableType.Dropper         =>         if(DropperItem := B.Droppers[I]){DropperItem.Load(Player)}

            PurchaseableType.Conveyor        =>         if(ConveyorItem := B.Conveyors[I]){ConveyorItem.Load(Player)}

            PurchaseableType.Shootable       =>         if(ShootableItem := B.Shootables[I]){ShootableItem.Load(Player)}

            PurchaseableType.Hitable         =>         if(HitableItem := B.Hitables[I]){HitableItem.Load(Player)}

            PurchaseableType.DanceFloor      =>         if(DanceFloorItem := B.DanceFloors[I]){DanceFloorItem.Load(Player)}
        
            PurchaseableType.Pet             =>         if(PetItem := B.Pets[I]){PetItem.Load(Player)}
            
            


(Item:purchaseable).Load(Player:player):void={Item.OnBought(Player)}

        

PreventInf<public>()<suspends>:void=
    Sleep(0.0); return
    
(value:int).GetTrunc<public>(Base:base):string=

    metricprefixes := array{"", "K", "M", "B", "T", "Q", "Qu", "s", "S", "O", "N", "D"}

    if:
        Trunc := Base.Base_Setup.DecimalTruncation?
    then:
        Base.Owner.SL.Superlog("Input is {value}")
        for:
            I -> P:metricprefixes
        do:
            if:
                max := Pow(1000.0, ITF(I+1))
                min := Pow(1000.0, ITF(I))
                curdex := metricprefixes[I]
                Base.Owner.SL.Superlog("max {max} min {min} curdex {curdex}")
                ITF(value) < max
            then:
                Base.Owner.SL.Superlog("Pre-Decimal Trunc is: {ITF(value)/min}{curdex}")
                return "{DecimalTrunc(ITF(value)/min, Trunc)}{curdex}"
            else:
                Base.Owner.SL.Superlog("Too small")
    else:
        return "{value}"
    
    return "ERROR CODE TRU001"

ITF(value:int)<transacts>:float=value*1.0

DecimalTrunc(value:float, decimals:int):string=

    if:
        StrValue := "{value}"
        Index := StrValue.Find["."[0]]
        ValueSliced := StrValue.Slice[0, Index+1+decimals]
        ValueMinimum := StrValue.Slice[0, Index]
        DecimalEnding := StrValue.Slice[Index, StrValue.Length]
    then:
        if:
            not DecimalEnding[1] = "0"[0]
        then:
            return "{ValueSliced}"
        else:
            return "{ValueMinimum}"
            
    return "ERROR CODE TRU002"


            




    
