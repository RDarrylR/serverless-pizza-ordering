import React from 'react';
import './OrderProgressBar.css';

const deliverySteps = [
  'Starting to process order',
  'Order is in the oven',
  'Sending out delivery',
  'Order was delivered'
];

const pickupSteps = [
  'Starting to process order',
  'Order is in the oven',
  'Order is ready for pickup'
];

const OrderProgressBar = ({ currentStep, lastUpdated, orderStatus, orderType }) => {
  const steps = orderType === 'delivery' ? deliverySteps : pickupSteps;
  return (
    <div className="order-progress-bar">
      <div className="progress-steps">
        {steps.map((step, index) => (
          <div
            key={step}
            className={`step ${index <= currentStep ? 'active' : ''}`}
          >
            {step}
          </div>
        ))}
      </div>
      <div className="progress-info">
        <h3>{steps[currentStep]}</h3>
        <p>Last updated: {lastUpdated.toLocaleString()}</p>
      </div>
    </div>
  );
};

export default OrderProgressBar;