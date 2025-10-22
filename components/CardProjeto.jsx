export default function CardProjeto({ projeto }) {
  return (
    <div className="bg-white p-4 rounded-lg shadow hover:shadow-lg transition">
      <h3 className="text-xl font-semibold mb-2">{projeto.titulo}</h3>
      <p className="text-gray-600 mb-4">{projeto.descricao}</p>
      <p className="font-bold mb-4">{projeto.valor}</p>
      <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition w-full">
        Ver Projeto
      </button>
    </div>
  );
}