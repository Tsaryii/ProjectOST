using{/Fortnite.com/Devices}
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using {cc}

tycoon_stomper <public> := class(creative_device):



    @editable var Bases <public> : []base = array{}

    @editable var SL <public> : log = log{}
    

    #When the game starts, tell the bases to start / initialize
    OnBegin<override>()<suspends>:void=
        for(I -> Base:Bases):
            Base.OnBegin(I)
            set Base.Owner = Self

            
               
                    
                
        


        


    