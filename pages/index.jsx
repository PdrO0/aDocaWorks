import Header from "../components/Header";
import Footer from "../components/Footer";
import CardProjeto from "../components/CardProjeto";

export default function Home() {
  const projetos = [
    { id: 1, titulo: "Site Institucional", descricao: "Criação de site responsivo", valor: "R$500" },
    { id: 2, titulo: "Loja Online", descricao: "E-commerce completo", valor: "R$1200" },
    { id: 3, titulo: "App Mobile", descricao: "Aplicativo Android/iOS", valor: "R$2000" },
  ];

  return (
    <div>
      <Header />
      <main className="container mx-auto p-4">
        <h2 className="text-3xl font-bold mb-6">Projetos Disponíveis</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {projetos.map(proj => (
            <CardProjeto key={proj.id} projeto={proj} />
          ))}
        </div>
      </main>
      <Footer />
    </div>
  );
}