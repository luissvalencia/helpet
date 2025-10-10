document.addEventListener('DOMContentLoaded', function() {
    const formulario = document.getElementById('formulario-login');
    
    formulario.addEventListener('submit', function(event) {
        let esValido = true;
        
        const email = document.getElementById('email');
        const password = document.getElementById('password');
        const tipoUsuario = document.getElementById('tipo_usuario');
        
        if (email.value.trim() === '') {
            alert('Por favor, ingresa tu correo electrónico.');
            esValido = false;
        }
        
        if (password.value === '') {
            alert('Por favor, ingresa tu contraseña.');
            esValido = false;
        }
        
        if (tipoUsuario.value === '') {
            alert('Por favor, selecciona el tipo de usuario.');
            esValido = false;
        }
        
        if (!esValido) {
            event.preventDefault();
        }
    });
});