using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using {cc}
<#>
    WIP Meant for 0.4.0
    This feature is a work in progress and is not yet complete.
    This is why it is not yet available in the game / base.
    Please be patient and wait for the feature to be completed.
computer_buyable<public>:=class<concrete><final>(fxpurchaseable):

    @editable var ComputerConfig : unique_computer_buyable = unique_computer_buyable{}
    var Ptype <override> :  PurchaseableType = PurchaseableType.Hitable


    Initialize<override>(Hostess:base, I:int):void=    
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)

        #Initalizes all the NPC spawners
        ComputerConfig.Initialize(Self)
        
        #Lists out all the properties of the item
        Detail("Computer Buyable")



 
    OnRebirth<override>():void=
        (super:)OnRebirth()

    GetStringParams<override>(P:?player)<transacts>:[string]string=
        var default : [string]string = (super:)GetStringParams(P)
        if:
            Owner := MaybeOwner?
            Player := P?
            Rebirths := GetCoreStats[Player, Owner.Base_Setup.PersistenceCore].Rebirths
            RebirthedOnHitGrantAmount := GetRebirthAmount[Owner, Rebirths, ComputerConfig.GrantAmount]
        then:
            set default = MergeStringMaps(default, map{"[GrantAmount(Param:RebirthValue)]" => "{RebirthedOnHitGrantAmount.GetTrunc(Owner)}"})
        if:
           Interval :=  ComputerConfig.GrantInterval?
        then:
            set default = MergeStringMaps(default, map{"[GrantInterval]" => "{Interval}"})
        set default = MergeStringMaps(default, map{
                "[CurrencyToReceiveID]" => "{ComputerConfig.CurrencyToReceiveID}",
                "[GrantAmount]" => "{ComputerConfig.GrantAmount}"
            })
        

        return default


    Host<override>()<suspends>:void={}


unique_computer_buyable:=class<concrete>(StringInaugurable):


    @editable var CurrencyToReceiveID  : int = {0}


    @editable var GrantAmount : int = {0}

    
    @editable var GrantInterval : ?float = option{1.0}


    #Initializes the item
    @editable var OverrideHudConfig : ?hud_main = option{hud_main{OnFailedMessage := option{""}; OnSuccessMessage := option{"+[GrantAmount(Param:RebirthValue)]"}}}


    Initialize<override>(Hostess:StringReturnables):void=
        if.  HC := OverrideHudConfig?
        then.  HC.Initialize(Hostess)
           

