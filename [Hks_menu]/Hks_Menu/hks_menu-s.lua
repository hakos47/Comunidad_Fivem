RegisterServerEvent("exportEntity")
AddEventHandler( "exportEntity", function(target, type, hash, model, coords, heading, rotation)
    --Opens a file in Append mode ("a"), stores entity data
    local file = io.open("entity-data.txt", "a")
    io.output(file)
    io.write("(Entity: ", target, 
        ", \nEntity type: ", type, 
        ", \nEntity Hash: ", hash, 
        ", \nEntity Model: ", model, 
        ", \nEntity Coords: ", coords, 
        ", \nEntity Heading: ", heading, 
        ", \nEntity Rotation: ", rotation, "), \n")
    io.close(file)
end)