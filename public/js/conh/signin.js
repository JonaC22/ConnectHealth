$("#email").keyup(function (event) {
    if (event.keyCode == 13) {
        sendLogin();
    }
});
$("#inputPassword").keyup(function (event) {
    if (event.keyCode == 13) {
        sendLogin();
    }
});
function sendLogin() {
    var email = $("#email").val();
    var password = $("#inputPassword").val();
    toggleLoading(true);
    $.post("/api/login", {"session": {"email": email, "password": password, "remember_me": "1" }})
        .done(function (data) {
            console.log(data);
            toggleLoading(false);
            window.location = "/index.html"
        })
        .fail(function (jqXHR, textStatus, errorThrown) {
            console.log(textStatus);
            console.log(errorThrown);
            toggleLoading(false);
            if(jqXHR.status == 403){
                alert("El email o contraseña ingresado no es correcto.");
            }else {
                alert("Error: " + jqXHR.status + " " + errorThrown);
            }
        });
    return false;
}