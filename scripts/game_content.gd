extends RefCounted
class_name GameContent

var zones=[
{"name":"Garage Node","base":1.0,"unlock":0},{"name":"Drone Foundry","base":6.0,"unlock":2500},{"name":"Solar Grid","base":30.0,"unlock":25000},{"name":"AI District","base":150.0,"unlock":250000},{"name":"Robotics Harbor","base":750.0,"unlock":2500000},{"name":"Hyperloop Works","base":3750.0,"unlock":25000000},{"name":"Orbital Yard","base":18000.0,"unlock":250000000},{"name":"Lunar Industry","base":90000.0,"unlock":2500000000},{"name":"Quantum Campus","base":450000.0,"unlock":25000000000},{"name":"Mars Gateway","base":2200000.0,"unlock":250000000000},{"name":"Dyson Lab","base":11000000.0,"unlock":2500000000000},{"name":"Singularity Core","base":55000000.0,"unlock":25000000000000}
]
var rarity=["Common","Uncommon","Rare","Epic","Legendary","Mythic"]
func upgrades()->Array:
    var out=[]
    for i in range(108):
        var tier=i/9
        out.append({"id":"u%03d"%i,"name":"%s Protocol %02d"%[zones[min(tier,zones.size()-1)].name,(i%9)+1],"zone":min(tier,zones.size()-1),"base_cost":25.0*pow(5.0,tier)*pow(1.7,i%9),"power":0.18+0.035*(i%9),"max":25})
    return out
func collectibles()->Array:
    var kinds=["Drone","Rover","Robot","Chip","Vehicle","Blueprint","AI","Reactor","Satellite","Skin"]
    var out=[]
    for i in range(60):
        out.append({"id":"c%03d"%i,"name":"%s-%02d"%[kinds[i%kinds.size()],i+1],"rarity":rarity[min(5,int(i/10))],"bonus":0.01+(i%10)*0.005,"desc":"Prototype asset from generation %d."%(1+int(i/10))})
    return out
func achievements()->Array:
    var out=[]
    for i in range(60):
        var typ=["earn","tap","upgrade","collect","prestige","zone"][i%6]
        var target=pow(10.0,1+int(i/6)) if typ=="earn" else (i+1)*5
        if typ=="prestige": target=1+int(i/12)
        if typ=="zone": target=1+int(i/6)
        out.append({"id":"a%03d"%i,"name":"Milestone %02d"%(i+1),"type":typ,"target":target,"reward":20+10*i,"secret":i in [17,41,59]})
    return out
func quests()->Array:
    var out=[]
    for i in range(36):
        var typ=["earn","tap","upgrade","collect"][i%4]
        out.append({"id":"q%03d"%i,"name":"City Contract %02d"%(i+1),"type":typ,"target":50.0*pow(2.3,i),"reward":75.0*pow(1.9,i)})
    return out
