document.addEventListener("DOMContentLoaded", () => {
  cargarSolicitudes();
});

function cargarSolicitudes() {
  fetch("../php/get_solicitudes_pendientes.php")
    .then(res => res.json())
    .then(data => {
      const cont = document.getElementById("solicitudes");
      if (!data.length) {
        cont.innerHTML = "<p>No tienes solicitudes pendientes.</p>";
        return;
      }

      cont.innerHTML = data.map(s => `
        <div class="solicitud-card">
          <link rel="stylesheet" href="../assets/css/dashboard.css">
          <p><strong>Dueño:</strong> ${s.duenio}</p>
          <p><strong>Mascota:</strong> ${s.mascota}</p>
          <p><strong>Fecha:</strong> ${s.fecha}</p>
          <p><strong>Estado:</strong> ${s.estado}</p>
          <button onclick="responderSolicitud(${s.id}, 'aceptar')">✅ Aceptar</button>
          <button onclick="responderSolicitud(${s.id}, 'rechazar')">❌ Rechazar</button>
        </div>
      `).join("");
    });
}

function responderSolicitud(id, accion) {
  const formData = new FormData();
  formData.append("solicitud_id", id);
  formData.append("accion", accion);

  fetch("../php/responder_solicitud.php", {
    method: "POST",
    body: formData
  })
    .then(res => res.json())
    .then(data => {
      alert(data.msg);
      cargarSolicitudes();
    });
}
