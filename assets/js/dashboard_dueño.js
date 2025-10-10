// Cargar lista de mascotas del usuario
fetch("../php/get_mascotas.php")
  .then(res => res.json())
  .then(data => {
    const cont = document.getElementById("lista-mascotas");

    cont.innerHTML = data.map(m => `
      <div class="mascota-card">
        <h3>${m.nombre}</h3>
        <p>${m.especie} - ${m.edad} años</p>
        <button onclick="abrirPaseos(${m.id}, '${m.nombre}')">Ir a Paseos</button>
      </div>
    `).join("");
  });

// Guardar mascota seleccionada y mostrar sección paseos
function abrirPaseos(mascotaId, nombreMascota) {
  // Guardamos en localStorage para usarlo en paseos.js
  localStorage.setItem("mascota_id", mascotaId);
  localStorage.setItem("mascota_nombre", nombreMascota);

  // Seleccionamos automáticamente en el dropdown
  const mascotaSelect = document.getElementById("mascota-select");
  if (mascotaSelect) {
    mascotaSelect.innerHTML = `<option value="${mascotaId}" selected>${nombreMascota}</option>`;
  }

  // Mostramos la sección Paseos
  document.getElementById("paseos").scrollIntoView({ behavior: "smooth" });
}
