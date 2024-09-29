import React from 'react';
import { Link } from 'react-router-dom';

function Home() {
  return (
    <div style={styles.container}>
      <h2 style={styles.title}>Welcome to Cloud Pizzeria</h2>
      <p style={styles.description}>Browse our fine selection of pizzas!</p>
      <div style={styles.buttonContainer}>
        <Link to="/products" style={styles.button}>View Products</Link>
        <Link to="/cart" style={styles.button}>View Cart</Link>
        <Link to="/checkout" style={styles.button}>Checkout</Link>
      </div>
    </div>
  );
}

const styles = {
  container: {
    padding: '40px',
    textAlign: 'center',
    maxWidth: '800px',
    margin: '0 auto',
  },
  title: {
    fontSize: '2.5em',
    color: '#131921',
    marginBottom: '20px',
  },
  description: {
    fontSize: '1.2em',
    color: '#333',
    marginBottom: '30px',
  },
  buttonContainer: {
    display: 'flex',
    justifyContent: 'center',
    gap: '20px',
    flexWrap: 'wrap',
  },
  button: {
    display: 'inline-block',
    padding: '12px 24px',
    backgroundColor: '#f0c14b',
    color: '#111',
    textDecoration: 'none',
    borderRadius: '4px',
    fontSize: '1em',
    fontWeight: 'bold',
    border: '1px solid #a88734',
    cursor: 'pointer',
    transition: 'background-color 0.3s',
  },
};

export default Home;