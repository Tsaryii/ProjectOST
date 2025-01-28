using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com}
using { /UnrealEngine.com/Temporary/SpatialMath }
using {cc}

unique_collectable<public> := class<concrete>(Inaugurable, Detailable):

    @editable Name : string = "My Collectable Group"
    @editable Description : string = "My Collectable Group's Description"
    @editable var  BypassZone <public> : logic = {false}
    @editable Collectables : []collectible_object_device = array{}
    @editable CurrencyToGiveID : int = 0
    @editable CurrencyToGiveAmount : int = 0
    @editable ExperiencePointsToAdd  : int = {0}
    var MaybeOwner : ?base = false

    Show<public>(Base:base):void=
        set MaybeOwner = option. Base
        for:
            CItem:Collectables
        do:
            CItem.Show()
            for(Player:Base.Players):
                CItem.Respawn(Player)


    Initialize<override>(Base:base):void=
        Detail("CollectableItem")
        for:
            CItem:Collectables 
        do:
            spawn{Inaugruation(Base, CItem)}

    Inaugruation(Hostess:base, CollectableItem:collectible_object_device)<suspends>:void=
        loop:
            Agent := CollectableItem.CollectedEvent.Await()
            if:
                Player:= player[Agent]
                Owner := MaybeOwner?
            then:
                GrantMoney(Base:=Hostess, Player, GrantID:=CurrencyToGiveID, Amount:=CurrencyToGiveAmount, BypassZone)
                UpdateXP(Player, ExperiencePointsToAdd, Owner.Base_Setup.PersistenceCore)

        
    Detail<override>(Type:string)<transacts>:void=
        Print("==[{Type} Details]==")
        Print("Name: {Name}")
        Print("Description: {Description}")
        Print("CurrencyToGiveID: {CurrencyToGiveID}")
        Print("CurrencyToGiveAmount: {CurrencyToGiveAmount}")
