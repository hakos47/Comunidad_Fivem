$(function () {
    var objectType = null;
    var contextElement = document.getElementById("context-menu");
    var isAdmin = false;

    function display(bool) {
        if (bool) {
            $("#container").show();
            $("#close").show();
        } else {
            $("#container").hide();
            $("#close").hide();
        }
    }
    display(false) 
    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                display(true)
            } else {
                display(false)
                clearContextmenu()
            }
        }
        if (item.type === "objectData") {
            clearContextmenu();
            objectType = item.objectType;             
            isAdmin = item.admin;
            populateContextMenu(item.entityActionList);
        }
    })

    document.onkeyup = function (data) {
        if (data.which == 27 || data.which == 66) {
            document.getElementById("context-menu").classList.remove("active");
            clearObjectData();
            clearContextmenu();
            $.post('https://Hks_Menu/exit', JSON.stringify({}));
            return
        }
    };

    document.addEventListener("click", (e) => {
        $.post('https://Hks_Menu/action', JSON.stringify({action: e.target.id}));
        clearObjectData();
    })
    
    window.addEventListener("contextmenu",function(event){
        event.preventDefault();
        $.post('https://Hks_Menu/rightclick', JSON.stringify({}));
        clearContextmenu();
        contextElement.style.top = event.offsetY + "px";
        contextElement.style.left = event.offsetX + "px";
    });
    window.addEventListener("click",function(){
        document.getElementById("context-menu").classList.remove("active");
    });
 
    function clearObjectData(){
        objectType = null;
        doorIndex = null;
    }

    function addHr(){
       node = document.createElement("hr");
       node.classList.add('.hrclass')
       
        //document.getElementById("context-menu").appendChild(node); // aqui colo camos barra divisoria
    }

    function populateContextMenu(entitySelfActions){
        if (entitySelfActions != undefined && entitySelfActions != null){
            if (entitySelfActions.singleButtons != undefined && entitySelfActions.singleButtons != null && entitySelfActions.singleButtons.length > 0){
                buildSingleButtons(entitySelfActions.singleButtons)
                addHr();
            }
            if (entitySelfActions.subMenus != undefined && entitySelfActions.subMenus != null && entitySelfActions.subMenus.length > 0){
                buildSubMenus(entitySelfActions.subMenus)
                
            }
        }
        addHr();
        createMenuItem("Examinar", "examine", false);
        createMenuItem("Cerrar", "close", false);
        contextElement.classList.add("active");
    }

    function buildSingleButtons(singleButtons){
        for(var i = 0; i < singleButtons.length; i++){
            createMenuItem(upperCaseFirstLetter(singleButtons[i].label), singleButtons[i].action, false);
        }
    }

    function buildSubMenus(subMenus){
        for(var i = 0; i < subMenus.length; i++){
            createMenuItem(subMenus[i].subLabel, subMenus[i].subName + "-menu", true, subMenus[i].subColor);
            createSubMenu(subMenus[i].subName + "-sub-menu", subMenus[i].subName + "-menu");
            createSubMenuItems(subMenus[i].actions, subMenus[i].subName + "-sub-menu", subMenus[i].subColor);
        }
    }

    function clearContextmenu(){
        var item = document.getElementById("context-menu");
        item.innerHTML = ''; //<--- Look into a CLEANER option.
    }

    function createMenuItem(name, id, isSub, color){
        var node;
        var textnode;
        node = document.createElement("div");
        textnode = document.createTextNode(name);
        node.setAttribute("id", id);
        node.classList.add("menu-item");
        if(isSub){
            node.classList.add("sub-menu");  
        }        
        if(color != undefined && color != null){
            node.classList.add(color);
        }else{
            node.classList.add("default");
        }
        node.appendChild(textnode);
        document.getElementById("context-menu").appendChild(node);
    }

    function createSubMenu(subMenu, parentNode){
        var node = document.createElement("div");
        node.setAttribute("id", subMenu);
        node.classList.add("inside-sub-menu");  
        document.getElementById(parentNode).appendChild(node);
    }

    function createSubMenuItems(str, submenu, color){
        console.log(JSON.stringify(str))
        var node;
        var textnode;
        for (i = 0; i < str.length; ++i)
        {
            node = document.createElement("div");
            textnode = document.createTextNode(upperCaseFirstLetter(str[i].label));
            node.setAttribute("id", str[i].action.replace(/\s/g, ""));
            node.classList.add("menu-item");
            if(color != undefined && color != null){
                node.classList.add(color);
            }else{
                node.classList.add("default");
            }
            node.appendChild(textnode);
            document.getElementById(submenu).appendChild(node);
        }
    }
    
    function upperCaseFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    function sleep(milliseconds) {
        const date = Date.now();
        let currentDate = null;
        do {
            currentDate = Date.now();
        } while (currentDate - date < milliseconds);
    }
})