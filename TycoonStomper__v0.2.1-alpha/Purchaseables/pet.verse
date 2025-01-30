using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using {/Fortnite.com/Teams}
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using {cc}
pet<public>:=class<concrete><final>(purchaseable):

    @editable var petConfig : unique_pet_buyable = unique_pet_buyable{}
    var Ptype <override> :  PurchaseableType = PurchaseableType.Pet

    UpMovementKeyFrame : keyframe_delta = keyframe_delta{
        DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := 30.0 }
        DeltaRotation := IdentityRotation()
        DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
        Time := 0.85
        Interpolation := Ease
    }
    DownMovementKeyFrame : keyframe_delta = keyframe_delta{
        DeltaLocation := vector3{ X := 0.0, Y := 0.0, Z := -30.0 }
        DeltaRotation := IdentityRotation()
        DeltaScale := vector3{ X := 1.0, Y := 1.0, Z := 1.0 }
        Time := 0.85
        Interpolation := Ease
    }



    Initialize<override>(Hostess:base, I:int):void=    
        #Calls the parent class's Initialize method
        (super:)Initialize(Hostess, I)

        #Initalizes the pet
        petConfig.Initialize(Hostess)
        
        #Lists out all the properties of the item
        Detail("hitableBuyable")


        

 
        
    #Host the pet by managing when its prop moves.
    Host<override>()<suspends>:void=
        petConfig.Show()
        petConfig.spawn_pet.Enable()
        AwaitButtonPress()
        
    AwaitButtonPress<private>()<suspends>:void=
        loop:
            Agent := petConfig.toggle.Await()
            if:
                Player := player[Agent]
                Mapped := Owner.PlayerToPetMap[Player]
            then:
                if:
                    Mapped(1) = false
                then:
                    race:
                        block: 
                            AsyncPetFollow(Player)
                        block: 
                            petConfig.toggle.Await()
                            if(set Owner.PlayerToPetMap[Player] = (Self, false)){}
                        block:
                            MaxReached(Player)
                            
                else:
                    Print("Pet max reached")
                    Owner.petmaxreached.Signal(Player)
                    if(PetS := Owner.PlayerToPetMap[Player]){if(set Owner.PlayerToPetMap[Player] = (pet{}, false)){}}
                    race:
                        block: 
                            AsyncPetFollow(Player)
                        block: 
                            petConfig.toggle.Await()
                            if(set Owner.PlayerToPetMap[Player] = (Self, false)){}
                        block:
                            MaxReached(Player)
                    
                    

                        
        PreventInf();

    MaxReached(Player:player)<suspends>:void=
        loop:
            OutPlayer := Owner.petmaxreached.Await()
            if:
                OutPlayer = Player
            then:
                return; 


    

    AsyncPetFollow(Player:player)<suspends>:void=
        if(set Owner.PlayerToPetMap[Player] = (Self, true)){}
        FollowDistance : float = 200.0
        WaitDistance : float = 150.0
        SleepTime : float = 0.6

        IdleAnimationKeyFrames := array
        {
            UpMovementKeyFrame, DownMovementKeyFrame
        }
        IdleAnimationKeyFrames
        loop:
            Sleep(SleepTime)
                PetProp : creative_prop = petConfig.pet_prop
                if:
                    FortCharacter := Player.GetFortCharacter[]
                then:
                    PetLoc : vector3 = PetProp.GetTransform().Translation
                    PlayerLoc : vector3 = FortCharacter.GetTransform().Translation
                    DistanceToPlayer : float = Distance(PetLoc, PlayerLoc)

                    if (DistanceToPlayer >= FollowDistance):
                        if (Direction := (PlayerLoc - PetLoc).MakeUnitVector[]):
                            DistanceToTravel : float = DistanceToPlayer - WaitDistance
                            var LocationToTravel : vector3 = PetLoc + (Direction * DistanceToTravel)

                            set petConfig.animating = false

                            if (PropAnimController := PetProp.GetAnimationController[]):
                                PropAnimController.Stop()

                            PlayerRotation := FortCharacter.GetTransform().Rotation
                            spawn{ PetProp.MoveTo(LocationToTravel, PlayerRotation, SleepTime) }
                    else:
                        if (petConfig.animating = false):
                            set petConfig.animating = true
                            if (PropAnimController := PetProp.GetAnimationController[]):
                                PropAnimController.SetAnimation(IdleAnimationKeyFrames, ?Mode := animation_mode.Loop)
                                PropAnimController.Play()

    


unique_pet_buyable:=class<concrete>(Inaugurable, Hostable):

    @editable pet_prop : creative_prop = creative_prop{}
    @editable spawn_pet : button_device = button_device{}

    toggle : event(agent) = event(agent){}

    Interact(Agent:agent):void={toggle.Signal(Agent); Print("Interacted")}
    
    var animating : logic = false

    Initialize<override>(Base:base):void=
        Hide()
        spawn_pet.Disable()
        spawn{Host()}

    Host<override>()<suspends>:void={
        loop:
            Agent := spawn_pet.InteractedWithEvent.Await()
            toggle.Signal(Agent)
    }

    Hide():void={pet_prop.Hide()}
    Show():void={pet_prop.Show()}
        
        
            


    


