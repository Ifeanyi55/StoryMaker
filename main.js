document
    .addEventListener("keydown",function(event){
        if(event.key === "Enter"){
            event.preventDefault();
            document.getElementById("create").click();
        }
    })