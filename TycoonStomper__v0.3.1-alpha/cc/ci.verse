using { /Verse.org/Random }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using {Purchaseables}
using {Runtimeinstantiables}
using {cc}


    
#██╗███╗░░██╗████████╗███████╗██████╗░███████╗░█████╗░░█████╗░███████╗░██████╗
#██║████╗░██║╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
#██║██╔██╗██║░░░██║░░░█████╗░░██████╔╝█████╗░░███████║██║░░╚═╝█████╗░░╚█████╗░
#██║██║╚████║░░░██║░░░██╔══╝░░██╔══██╗██╔══╝░░██╔══██║██║░░██╗██╔══╝░░░╚═══██╗
#██║██║░╚███║░░░██║░░░███████╗██║░░██║██║░░░░░██║░░██║╚█████╔╝███████╗██████╔╝
#╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚══════╝╚═════╝░
Detailable<public>:=interface():

    Detail<public>():void


Inaugurable<public>:=interface():
    
    Initialize<public>(Base:base):void

SuperInaugurable<public>:=interface():
    
    Initialize<public>(Base:base, I:int):void

Toggleable<public>:=interface():
    Enable<public>():void
    Disable<public>():void

Hostable<public>:=interface():
    Host<public>()<suspends>:void

SubHostable<public>:=interface():
    SubHost<public>()<suspends>:void

Rebirthable<public>:=interface():
    OnRebirth<public>():void

Runtime<public>:=interface():
    OnBegin<public>(IX:int):void

RuntimeInaugurable<public>:=interface():
    OnBegin<public>(Base:base, IX:int):void

LogicalInagurable<public>:=interface():
    Initialize<public>(Base:base, altvalue:logic):void


FXSystem<public>:=interface():

    OnEvent<public>():void

    EndEvent<public>():void

IntegralFX<public>:=interface(IntegralVisuals, IntegralAudibles):
    InitializeFX<public>():void

IntegralVisuals<public>:=interface():
    InitalizeVisuals<public>():void


IntegralAudibles<public>:=interface():
    InitalizeAudibles<public>():void

ExpandedFX<public>:=interface(IntegralFX, ExpandedVisuals, ExpandedAudibles):

    PlayFX<public>():void

    StopFX<public>():void

ExpandedAudibles<public>:=interface():
    PlayAudibles<public>():void

    StopAudibles<public>():void

ExpandedVisuals<public>:=interface():
    PlayVisuals<public>():void

    StopVisuals<public>():void





#THIS CONSTRUCTOR IS NO LONGER IN USE
#Use at your own risk
#███████╗███╗░░░███╗░█████╗░██████╗░███████╗
ConstructBase<constructor>(Src:base)<transacts>:=base:
    selfindex := Src.selfindex
    Status := Src.Status
    Players := Src.Players
    Owner := Src.Owner
    MoneyLeague := Src.MoneyLeague
    Base_Setup := Src.Base_Setup
    BasicProps := Src.BasicProps
    Collectables := Src.Collectables
    Conveyors := Src.Conveyors
    Currencies := Src.Currencies
    DanceFloors := Src.DanceFloors
    Droppers := Src.Droppers
    Gifts := Src.Gifts
    Hitables := Src.Hitables
    MoneyWheel := Src.MoneyWheel
    NPCSpawners := Src.NPCSpawners
    Shootables := Src.Shootables
    UIConfig := Src.UIConfig

    