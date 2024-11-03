using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Native }
using {Purchaseables}
using {Runtimeinstantiables}
using {Stomper}

<#

░█████╗░██╗░░░██╗░██████╗████████╗░█████╗░███╗░░░███╗
██╔══██╗██║░░░██║██╔════╝╚══██╔══╝██╔══██╗████╗░████║
██║░░╚═╝██║░░░██║╚█████╗░░░░██║░░░██║░░██║██╔████╔██║
██║░░██╗██║░░░██║░╚═══██╗░░░██║░░░██║░░██║██║╚██╔╝██║
╚█████╔╝╚██████╔╝██████╔╝░░░██║░░░╚█████╔╝██║░╚═╝░██║
░╚════╝░░╚═════╝░╚═════╝░░░░╚═╝░░░░╚════╝░╚═╝░░░░░╚═╝

███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗░░░██╗░░░██╗███████╗██████╗░░██████╗███████╗
██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝░░░██║░░░██║██╔════╝██╔══██╗██╔════╝██╔════╝
█████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░░░░╚██╗░██╔╝█████╗░░██████╔╝╚█████╗░█████╗░░
██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗░░░░╚████╔╝░██╔══╝░░██╔══██╗░╚═══██╗██╔══╝░░
██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝██╗░░╚██╔╝░░███████╗██║░░██║██████╔╝███████╗
╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═════╝░╚══════╝
@tsarry
#>

#Change this to true to enable the global superlog system
#The global superlog system will print all superlogs to the console
#Super logs are for almost everything so this will clutter the console
#This is useful for mass debugging purposes otherwise keep it off
UseGlobalSuperLog: logic = false

GlobalSuperlog<public>(I:string)<transacts>:void=
    if:
        UseGlobalSuperLog? or UsingDebug[GetSession()]?
    then: 
        Print("{I}")

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
                Bypass? or not HasZone[Base, GrantID]
            then:
                UpdateAssociatedCurrencies(Player, GrantID, AmountToGrant+CurrentValue)
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
    return Round[(Pow(Base.Base_Setup.RebirthConfig.RebirthCashMultiplier, Rebirths*1.0) * Amount)]

GetRebirthCostAmount<public>(Base:base, Rebirths:int)<decides><transacts>:int=
    return Round[(Pow(Base.Base_Setup.RebirthConfig.RebirthCostMultiplier, Rebirths*1.0) * Base.Base_Setup.RebirthConfig.RebirthCost)]

GrantXP<public>(Base:base, Player:player, Amount:int)<transacts>:void={}
    
condition<public>:=struct<concrete>():
    @editable MinCurrencyAmount <public>: int = 0
    @editable MinPlayerExperience <public>: int = 0
    @editable MinRebirths <public> : int = 0

GetConveyorConfig<public>(Base:base, ID:int)<decides><transacts>:custom_conveyor=
    {
        Prim := for:
            I -> C:Base.Conveyors
            I = ID
        do:
            C
        Prim[0].ConveyorConfig
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
        Rebirths := Stats.Rebirths

        Money >= Condition.MinCurrencyAmount
        Experience >= Condition.MinPlayerExperience
        Rebirths >= Condition.MinRebirths
        return
        
CanBuy<public>(Player:player, SP:purchaseable)<decides><transacts>:void=
    Stats := GetStats[Player]
    Money := Stats.AssociatedCurrencies[SP.CurrencyToSpendID]
    Cost := SP.Price


    Money >= Cost
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

            PurchaseableType.Upgrader       =>         if(UpgraderItem := B.Upgraders[I]){UpgraderItem.Load(Player)}
            
            


(Item:purchaseable).Load(Player:player):void={Item.OnBought(Player)}

        

PreventInf<public>()<suspends>:void=
    Sleep(0.0); return
    
(value:int).GetTrunc<public>(Base:base)<transacts>:string=

    metricprefixes := array{"", "K", "M", "B", "T", "Q", "Qu", "s", "S", "O", "N", "D"}

    if:
        Trunc := Base.Base_Setup.DecimalTruncation?
    then:
        Base.Owner.Config.Superlog("Input is {value}")
        for:
            I -> P:metricprefixes
        do:
            if:
                max := Pow(1000.0, ITF(I+1))
                min := Pow(1000.0, ITF(I))
                curdex := metricprefixes[I]
                Base.Owner.Config.Superlog("max {max} min {min} curdex {curdex}")
                ITF(value) < max
            then:
                Base.Owner.Config.Superlog("Pre-Decimal Trunc is: {ITF(value)/min}{curdex}")
                return "{DecimalTrunc(ITF(value)/min, Trunc)}{curdex}"
            else:
                Base.Owner.Config.Superlog("Too small")
    else:
        return "{value}"
    
    return "ERROR CODE TRU001"

ITF(value:int)<transacts>:float=value*1.0

DecimalTrunc(value:float, decimals:int)<transacts>:string=

    if:
        StrValue := "{value}"
        Index := StrValue.Find["."[0]]
        ValueSliced := StrValue.Slice[0, Index+1+decimals]
        ValueMinimum := StrValue.Slice[0, Index]
        DecimalEnding := StrValue.Slice[Index, StrValue.Length]
    then:
        if:
            not DecimalEnding[1] = "0"[0] and not decimals = 0
        then:
            return "{ValueSliced}"
        else:
            return "{ValueMinimum}"
            
    return "ERROR CODE TRU002"



# > > > > > Interface methods



GetStringParmaters<public>(MaybeP:?player, S:string, ParamList:StringReturnables)<transacts><decides>:string=
        var CurrentString : string = S
        var CurrentParams : [string]string = map{}
        if:
            P := MaybeP?
        then:
            GlobalSuperlog("Had Player")
            MyParams := ParamList.GetStringParams(option{P})
            set CurrentParams = MyParams
        else:
            set CurrentParams = ParamList.GetStringParams(false)
        S.Length >= 1
        loop:
            if:
                Sdex := CurrentString.Find["["[0]]
                Edex := CurrentString.Find["]"[0]]
                Value := CurrentString.Slice[Sdex, Edex+1]
            then:
                if:
                    FoundValue := CurrentParams[Value]
                    RemovedDex := CurrentString.Remove[Sdex, Edex+1]
                    FinalString := RemovedDex.Insert[Sdex, FoundValue]
                then:
                    set CurrentString = FinalString
                else if:
                    RemovedDex := CurrentString.Remove[Sdex, Edex+1]
                    set CurrentString = RemovedDex
                else:
                    break
            else:
                break
        
        return CurrentString


GroupedInitialize<public>(Base:base, Input:[][]SuperInaugurable):void=
    for:
        I -> E:Input
    do:
        for:
            J -> F:E
        do:
            F.Initialize(Base, J)
    return


Parent<public>(Type:[]purchaseable):[]SuperInaugurable=
    for:
        E:Type
    do:
        E.PoorsMansInit()

MergeStringMaps<public>(Map1:[string]string, Map2:[string]string)<transacts>:[string]string=
    var ReturnMap : [string]string = map{}
    for:
        Key -> Value:Map1
    do{if. set ReturnMap[Key] = Value}

    for:
        Key -> Value:Map2
    do{if. set ReturnMap[Key] = Value}

        

    ReturnMap
(PurchaseableList:[][]t where t:subtype(SuperInaugurable)).InitList<public>(Base:base):void={
    for:
        PurchaseSet : PurchaseableList
    do:
        for:
            IX -> PurchaseAble : PurchaseSet
        do:
            PurchaseAble.Initialize(Base, IX)
            
}





ownable := interface{
    Assign<public>(Player:player)<transacts>:void
    Clear<public>():void
    IsOwned<public>()<transacts><decides>:void
    GetOwner<public>()<transacts><decides>:player
}

#finds open ownable | assigns to player passed in
(Ownables:[]t where t:subtype(ownable)).FindAssignOpen(Player:player)<transacts><decides>:t={
    UnOwned := for(Ownable:Ownables, not Ownable.IsOwned[]){Ownable}
    Out_Ownable := UnOwned[0]
    Out_Ownable.Assign(Player)
    return Out_Ownable
}

#fetches first open ownable
(Ownables:[]t where t:subtype(ownable)).FetchOpen()<transacts><decides>:t={
    UnOwned := for(Ownable:Ownables, not Ownable.IsOwned[]){Ownable}
    UnOwned[0]
}

#clears all owned ownables
(Ownables:[]t where t:subtype(ownable)).ClearAll():void={
    for(Ownable:Ownables, Ownable.IsOwned[]){Ownable.Clear()}
}