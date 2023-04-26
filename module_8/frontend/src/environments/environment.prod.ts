import { Config } from './config.interface';

export const environment: Config = {
  production: true,
  apiEndpoints: {
    product: 'https://192.168.100.10/api',
    order: 'https://192.168.100.10/api',
    import: 'https://192.168.100.10/api',
    bff: 'https://192.168.100.10/api',
    cart: 'https://192.168.100.10/api',
  },
  apiEndpointsEnabled: {
    product: true,
    order: true,
    import: true,
    bff: true,
    cart: true,
  },
};
