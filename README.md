# ld-banking
Banking script for FiveM

## Dependencies
ld-target
PolyZone
drawtext UI

## How to Use
For add infos in your sql


    TriggerServerEvent("ld-updaterecents", ply, amount, comment, date, type, sender, target, iden)

    or

     TriggerEvent("ld-updaterecents", ply, amount, comment, date, type, sender, target, iden)



- ply = your identifier
- amount = money amount
- comment = comment
- date = current date (avalible in client)
- type = value "pos" or "neg"
- sender = sender
- target = target
- iden = ex: "WITHDRAW"

####

1. Run the SQL
