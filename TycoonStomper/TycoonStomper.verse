using{/Fortnite.com/Devices}
using { /Verse.org/Simulation }
using { /Verse.org/Random }

tycoon_stomper := class(creative_device):



    @editable var Bases : []base = array{}

    @editable var SL : log = log{}
    

    #When the game starts, tell the bases to start / initialize
    OnBegin<override>()<suspends>:void=
        for(I -> Base:Bases):
            Base.OnBegin(I)
            set Base.Owner = Self

    #REBIRTH IDEA
    #JUST CREATE AN INSTANCE OF THE BASE AND IF A PLAYER LEAVES JUST SPAWN IN THAT NEW INSTANCE

            
               
                    
                
        


        


    