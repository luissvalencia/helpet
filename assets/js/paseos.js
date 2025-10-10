// ==============================
// Variables globales
// ==============================
const mascotaId = localStorage.getItem("mascota_id");
const mascotaNombre = localStorage.getItem("mascota_nombre");

// ==============================
// Al cargar la página
// ==============================
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("mascota-info").innerText =
    "Mascota: " + (mascotaNombre || "Sin nombre");
  cargarPaseadores();
});

// ==============================
// Función para cargar paseadores
// ==============================
function cargarPaseadores() {
  fetch("../php/get_paseadores.php")
    .then(res => res.json())
    .then(data => {
      const cont = document.getElementById("subseccion-contenido");

      if (!data.length) {
        cont.innerHTML = "<p>No hay paseadores disponibles en este momento</p>";
        return;
      }

      cont.innerHTML = `
        <h3>Paseadores Disponibles</h3>
        <div class="paseadores-container">
          ${data.map(p => `
            <div class="paseador-card" id="paseador-${p.id}">
              <h3>${p.nombre}</h3>
              <p>Experiencia: ${p.experiencia} años</p>
              <p>Calificación: ⭐ ${p.calificacion_promedio || "N/A"}</p>
              <button onclick="mostrarFormulario(${p.id})">Solicitar Paseo</button>
              <div class="form-paseo hidden" id="form-${p.id}">
                <label>Fecha: 
                  <input type="date" id="fecha-${p.id}">
                </label>
                <label>Hora: 
                  <input type="time" id="hora-${p.id}">
                </label>
                <button onclick="confirmarPaseo(${p.id}, '${p.nombre}')">Confirmar</button>
              </div>
            </div>
          `).join("")}
        </div>
      `;
    })
    .catch(err => console.error("Error cargando paseadores:", err));
}

// ==============================
// Mostrar formulario en la tarjeta
// ==============================
function mostrarFormulario(paseadorId) {
  const form = document.getElementById(`form-${paseadorId}`);
  form.classList.toggle("hidden");
}

// ==============================
// Confirmar y enviar solicitud
// ==============================
function confirmarPaseo(paseadorId, paseadorNombre) {
  const fecha = document.getElementById(`fecha-${paseadorId}`).value;
  const hora = document.getElementById(`hora-${paseadorId}`).value;

  if (!fecha || !hora) {
    alert("Por favor selecciona fecha y hora");
    return;
  }

  const fechaCompleta = `${fecha} ${hora}`;

  // ✅ Aquí inicializamos formData ANTES de usarlo
  const formData = new FormData();
  formData.append("mascota_id", mascotaId);
  formData.append("paseador_id", paseadorId);
  formData.append("fecha", fechaCompleta);

  fetch("../php/solicitar_paseo.php", {
    method: "POST",
    body: formData
  })
    .then(res => res.json())
    .then(data => {
      console.log("Respuesta solicitar_paseo:", data); // Debug
      if (data.status === "ok") {
        alert(`✅ Paseo solicitado con ${paseadorNombre}`);
        document.getElementById(`form-${paseadorId}`).classList.add("hidden");
      } else {
        alert("❌ Error: " + data.msg);
        if (data.received) console.log("Campos recibidos:", data.received);
      }
    })
    .catch(err => console.error("Error solicitando paseo:", err));
}
