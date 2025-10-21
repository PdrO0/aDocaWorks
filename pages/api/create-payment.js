// endpoint server-side para criar preferência no MercadoPago
import mercadopago from 'mercadopago';

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN;
  if (!accessToken) return res.status(500).json({ error: 'MERCADOPAGO_ACCESS_TOKEN not configured' });

  mercadopago.configure({ access_token: accessToken });

  try {
    const { title, description, amount, projectId } = req.body;
    if (!amount || !title) return res.status(400).json({ error: 'Missing fields' });

    const preference = {
      items: [
        {
          title,
          description: description || '',
          quantity: 1,
          unit_price: Number(amount)
        }
      ],
      external_reference: projectId || null,
      back_urls: {
        success: process.env.NEXT_PUBLIC_RETURN_URL || `${process.env.NEXT_PUBLIC_APP_URL || ''}/dashboard`,
        failure: process.env.NEXT_PUBLIC_APP_URL || '/',
        pending: process.env.NEXT_PUBLIC_APP_URL || '/'
      },
      auto_return: 'approved'
    };

    const response = await mercadopago.preferences.create(preference);
    // response.body.init_point contém o URL de checkout
    return res.status(200).json({ init_point: response.body.init_point, id: response.body.id });
  } catch (err) {
    console.error('MP error', err);
    return res.status(500).json({ error: err.message || 'MercadoPago error' });
  }
}