using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using {cc}
dancefloor_buyable<public>:=class<concrete><final>(purchaseable):

    @editable var dancefloorconfig : unique_dancefloor_buyable = unique_dancefloor_buyable{}
    var Ptype <override> :  PurchaseableType = PurchaseableType.DanceFloor
    Initialize<override>(Hostess:base, I:int):void=
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)

        #Initalizes all the NPC spawners
        dancefloorconfig.Initialize(Hostess)
        
        #Lists out all the properties of the item
        Detail("DancefloorBuyable")

 
        
    #Host the Shoot
    Host<override>()<suspends>:void=
        dancefloorconfig.Enable()
        loop{
            Player := dancefloorconfig.OnEmote.Await()
            race:
                dancefloorconfig.OnEmoteStop.Await()
                GrantOvertime(Player)

        }
    GrantOvertime(Agent:agent)<suspends>:void=
        loop:
            if:
                Player := player[Agent]
            then:
                Sleep(dancefloorconfig.EmoteGrantInterval)
                GrantMoney(Owner, Player, dancefloorconfig.CurrencyOnEmoteID, dancefloorconfig.OnEmoteIntervalGrantAmount, BypassZone)
                GrantXP(Owner, Player, dancefloorconfig.OnEmoteIntervalExperienceAmount)
                HudConfig.OnSuccessfullPlayer(Player)

unique_dancefloor_buyable:=class<concrete>(Toggleable, Inaugurable):

    #The currency ID that will be granted to the player when the shooting range target is hit
    @editable var CurrencyOnEmoteID  : int = {0}

    #The amount of money that will be granted to the player when the shooting range target is hit
    @editable var OnEmoteIntervalGrantAmount : int = {0}

    #The amount of experience that will be granted to the player when the NPC is killed
    @editable var OnEmoteIntervalExperienceAmount : int = {0}

    @editable var EmoteGrantInterval : float = {0.5}
    
    #Shooting range target device that will be hit
    @editable var EmoteDetector : mutator_zone_device = mutator_zone_device{}

    OnEmote : event(agent) = event(agent){}
    OnEmoteStop : event(agent) = event(agent){}


    Disable<override>():void={EmoteDetector.Disable()}
    Enable<override>():void={EmoteDetector.Enable()}

    Initialize<override>(Base:base):void={
        Disable()
        spawn{AwaitEmote(Base)}
        spawn{AwaitEmoteEnd(Base)}
    }

    AwaitEmote(Base:base)<suspends>:void={
        loop:
            Player := EmoteDetector.AgentBeginsEmotingEvent.Await()
            OnEmote.Signal(Player)
    }
    AwaitEmoteEnd(Base:base)<suspends>:void={
        loop:
            Player := EmoteDetector.AgentEndsEmotingEvent.Await()
            OnEmoteStop.Signal(Player)
    }



