import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { CustomExceptionFilter } from './exception-filters/custom.exception-filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe());
  app.useGlobalFilters(new CustomExceptionFilter());
  app.enableCors({
    origin: ['http://localhost:4200', 'http://localhost:5000'],
  });
  await app.listen(process.env.APP_PORT || 3000);
}
bootstrap();
