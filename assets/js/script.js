// ==============================
// Funciones para registro rápido
// ==============================
function registrarDueno() {
  window.location.href = 'pages/registro.html?tipo=dueño';
}

function registrarPaseador() {
  window.location.href = 'pages/registro.html?tipo=paseador';
}

// ==============================
// Gestión de Mascotas en Dashboard
// ==============================
document.addEventListener("DOMContentLoaded", () => {
  const listaMascotas = document.getElementById("lista-mascotas");
  const formMascota = document.getElementById("form-mascota");

  // ==== Cargar mascotas ====
  function cargarMascotas() {
    fetch("../php/get_mascotas.php")
      .then(res => res.json())
      .then(data => {
        listaMascotas.innerHTML = "";
        if (data.length === 0) {
          listaMascotas.innerHTML = "<p>No tienes mascotas registradas.</p>";
        } else {
          data.forEach(m => {
            const div = document.createElement("div");
            div.classList.add("mascota-card");
            div.setAttribute("onclick", `abrirPaseos(${m.id}, '${m.nombre}')`);
            div.innerHTML = `
              <h3>${m.nombre}</h3>
              <p>${m.especie} - ${m.raza || "N/A"}</p>
              <p>Edad: ${m.edad || "N/A"}</p>
            `;
            listaMascotas.appendChild(div);
          });
        }
      });
  }

  cargarMascotas();

  // ==== Agregar mascota ====
  formMascota.addEventListener("submit", e => {
    e.preventDefault();
    const formData = new FormData(formMascota);

    fetch("../php/add_mascota.php", {
      method: "POST",
      body: formData
    })
      .then(res => res.text())
      .then(res => {
        if (res === "ok") {
          alert("Mascota agregada con éxito");
          formMascota.reset();
          cargarMascotas();
        } else {
          alert("Error: " + res);
        }
      });
  });
});

// ==============================
// Función para abrir la gestión de paseos
// ==============================
function abrirPaseos(id, nombre) {
  // Guardamos en localStorage para usar en paseos.html
  localStorage.setItem("mascota_id", id);
  localStorage.setItem("mascota_nombre", nombre);

  // Redirigimos a la página de paseos
  window.location.href = "paseos.html";
}
