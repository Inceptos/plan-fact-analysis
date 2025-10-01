import express from 'express';
import pkg from 'pg';
import cors from 'cors';

const { Pool } = pkg;
const app = express();
const port = process.env.PORT || 3000;

app.use(express.static('.'));
app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: process.env.DB_SSL === 'true'
});

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'OK', database: 'connected' });
  } catch (error) {
    res.status(500).json({ status: 'ERROR', database: error.message });
  }
});

app.get('/api/objects', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id as value, name as label 
      FROM ref_object 
      ORDER BY name
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/work-types', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id as value, name as label 
      FROM ref_type_work 
      ORDER BY name
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/report', async (req, res) => {
  const client = await pool.connect();
  
  try {
    let {
      start_date,
      end_date, 
      date_type = 'YYYY-MM',
      objects,
      work_types
    } = req.query;

    if (!start_date) {
      start_date = new Date();
      start_date.setFullYear(start_date.getFullYear() - 3);
      start_date = start_date.toISOString().split('T')[0];
    }

    if (!end_date) {
      end_date = new Date();
      end_date.setFullYear(end_date.getFullYear() + 1);
      end_date = end_date.toISOString().split('T')[0];
    }

    await client.query('BEGIN');

    const objectArray = objects ? objects.split(',').map(Number) : null;
    const workTypeArray = work_types ? work_types.split(',').map(Number) : null;

    await client.query(
      'CALL get_plan_fact_report($1, $2, $3, $4, $5)',
      [start_date, end_date, date_type, objectArray, workTypeArray]
    );

    const regularResult = await client.query('FETCH ALL FROM cumulative_cur');
    const cumulativeResult = await client.query('FETCH ALL FROM regular_cur');

    await client.query('COMMIT');

    res.json({
      success: true,
      data: {
        regular: regularResult.rows,     
        cumulative: cumulativeResult.rows 
      }
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error generating report:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  } finally {
    client.release();
  }
});

app.get('/', (req, res) => {
  res.json({ 
    message: 'API is running in Docker!',
    endpoints: [
      '/health',
      '/api/objects', 
      '/api/work-types',
      '/api/report'
    ]
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`API running on ${port}`);
});