using { /Verse.org/Simulation }

#FX
#██╗███╗░░██╗████████╗███████╗██████╗░███████╗░█████╗░░█████╗░███████╗░██████╗
#██║████╗░██║╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝
#██║██╔██╗██║░░░██║░░░█████╗░░██████╔╝█████╗░░███████║██║░░╚═╝█████╗░░╚█████╗░
#██║██║╚████║░░░██║░░░██╔══╝░░██╔══██╗██╔══╝░░██╔══██║██║░░██╗██╔══╝░░░╚═══██╗
#██║██║░╚███║░░░██║░░░███████╗██║░░██║██║░░░░░██║░░██║╚█████╔╝███████╗██████╔╝
#╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚══════╝╚═╝░░╚═╝╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚══════╝╚═════╝░

FXSystem<public>:=interface():

    OnEvent<public>(P:player):void

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