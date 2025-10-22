import Header from "../components/Header";
import Footer from "../components/Footer";

export default function Login() {
  return (
    <div>
      <Header />
      <main className="flex justify-center items-center min-h-screen bg-gray-50 p-4">
        <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
          <h2 className="text-2xl font-bold mb-6 text-center">Login</h2>
          <form className="space-y-4">
            <input type="email" placeholder="Email" className="w-full p-3 border rounded"/>
            <input type="password" placeholder="Senha" className="w-full p-3 border rounded"/>
            <button className="w-full bg-blue-600 text-white p-3 rounded hover:bg-blue-700 transition">Entrar</button>
          </form>
        </div>
      </main>
      <Footer />
    </div>
  );
}